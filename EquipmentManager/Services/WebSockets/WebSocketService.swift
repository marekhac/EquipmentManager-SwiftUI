//
//  WebSocketService.swift
//  EquipmentManager
//
//  Created by Marek Hac on 26/05/2026.
//

import Foundation
import OSLog

class WebSocketService: WebSocketProtocol {

    // MARK: - Public

    private(set) var isConnected = false

    let events: AsyncStream<StatusUpdateEvent>
    
    // MARK: - Private

    private let logger = Logger(
        subsystem: "EquipmentManager",
        category: "WebSocket"
    )

    private let url: URL
    private let session: URLSession
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private var webSocketTask: URLSessionWebSocketTask?

    private var receiveTask: Task<Void, Never>?
    private var pingTask: Task<Void, Never>?
    private var reconnectTask: Task<Void, Never>?

    private let continuation: AsyncStream<StatusUpdateEvent>.Continuation

    // MARK: - Init

    init(config: WebSocketConfig = .local, session: URLSession = .shared) {
        self.url = config.url
        self.session = session
        
        // Create stream + continuation
        
        let pair = AsyncStream.makeStream(of: StatusUpdateEvent.self)
        
        self.events = pair.stream
        self.continuation = pair.continuation
    }

    deinit {
        continuation.finish()
    }
}

// MARK: - Connection

extension WebSocketService {
    func connect() async {
        disconnect()

        logger.info("Connecting websocket")
        let task = session.webSocketTask(with: url)

        webSocketTask = task
        task.resume()

        receiveTask = Task {
            await receiveLoop()
        }

        pingTask = Task {
            await pingLoop()
        }
    }

    func disconnect() {
        logger.info("Disconnecting websocket")

        receiveTask?.cancel()
        pingTask?.cancel()
        reconnectTask?.cancel()

        receiveTask = nil
        pingTask = nil
        reconnectTask = nil

        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil

        isConnected = false
    }
}

// MARK: - Receive

private extension WebSocketService {
    func receiveLoop() async {

        guard let webSocketTask else { return }
        while !Task.isCancelled {
            let message: URLSessionWebSocketTask.Message
            do {
                message = try await webSocketTask.receive()
            } catch {
                await handleFailure(error)
                return
            }

            do {
                try handle(message)
                if !isConnected {
                    isConnected = true
                }
            } catch {
                let error = WebSocketError.malformedMessage(error)
                logger.error("\(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Ping

private extension WebSocketService {
    func pingLoop() async {
        while !Task.isCancelled {
            do {
                try await sendPing()
                if !isConnected {
                    isConnected = true
                }
                try await Task.sleep(for: .seconds(10))
            } catch {
                await handleFailure(error)
                return
            }
        }
    }

    func sendPing() async throws {
        guard let webSocketTask else {
            throw WebSocketError.notConnected
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            webSocketTask.sendPing { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}

// MARK: - Message Handling

private extension WebSocketService {
    func handle(_ message: URLSessionWebSocketTask.Message) throws {
        let data = try messageData(from: message)
        let decoded = try decoder.decode(WebSocketMessage.self, from: data)

        let event = StatusUpdateEvent(equipmentId: decoded.equipmentId, status: decoded.status)

        continuation.yield(event)
    }

    func messageData(from message: URLSessionWebSocketTask.Message) throws -> Data {
        switch message {
        case .data(let data):
            return data

        case .string(let text):
            guard let data = text.data(using: .utf8) else {
                throw WebSocketError.invalidUTF8
            }
            return data

        @unknown default:
            throw WebSocketError.unknownMessageType
        }
    }
}

// MARK: - Failure Handling

private extension WebSocketService {
    func handleFailure(_ error: Error) async {
        logger.error(
            "WebSocket failure: \(error.localizedDescription)"
        )
        
        isConnected = false
        await reconnect()
    }
    
    func reconnect() async {
        reconnectTask?.cancel()
        reconnectTask = Task {
            do {
                try await Task.sleep(for: .seconds(3))
                guard !Task.isCancelled else { return }
                await connect()
                
            } catch is CancellationError {
                // superseded by a newer reconnect or by disconnect()
            } catch {
                await handleFailure(error)
            }
        }
    }
}
