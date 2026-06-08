//
//  WebSocketService.swift
//  EquipmentManager
//
//  Created by Marek Hac on 26/05/2026.
//

import Foundation
import OSLog

actor WebSocketService: WebSocketProtocol {

    // MARK: - Public

    let events: AsyncStream<StatusUpdateEvent>
    let connectionState: AsyncStream<Bool>
    
    // MARK: - Private

    private let logger = Logger(
        subsystem: "EquipmentManager",
        category: "WebSocket"
    )

    private(set) var isConnected = false
    
    private let continuation: AsyncStream<StatusUpdateEvent>.Continuation
    private let connectionContinuation: AsyncStream<Bool>.Continuation
    private let url: URL
    private let session: URLSession
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private var webSocketTask: URLSessionWebSocketTask?

    private var receiveTask: Task<Void, Never>?
    private var pingTask: Task<Void, Never>?
    private var reconnectTask: Task<Void, Never>?

    // MARK: - Init

    init(config: WebSocketConfig = .local, session: URLSession = .shared) {
        self.url = config.url
        self.session = session
        
        // Create stream + continuation
        
        let pair = AsyncStream.makeStream(
            of: StatusUpdateEvent.self,
            bufferingPolicy: .bufferingNewest(1)
        )
        
        self.events = pair.stream
        self.continuation = pair.continuation
        
        let connectionPair = AsyncStream.makeStream(
            of: Bool.self,
            bufferingPolicy: .bufferingNewest(1)
        )
        
        self.connectionState = connectionPair.stream
        self.connectionContinuation = connectionPair.continuation
    }

    deinit {
        continuation.finish()
    }
}

// MARK: - Public API

extension WebSocketService {
    func connect() async {
        await disconnect()

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

    func disconnect() async {
        logger.info("Disconnecting websocket")

        cancelTasks()

        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil

        updateConnectionState(false)
    }
}

// MARK: - Connection Loops

private extension WebSocketService {
    func receiveLoop() async {
        guard let webSocketTask else { return }
        while !Task.isCancelled {
            do {
                let message = try await webSocketTask.receive()
                try handle(message)
            } catch {
                await handleFailure(error)
                return
            }
        }
    }

    func pingLoop() async {
        while !Task.isCancelled {
            do {
                try await sendPing()
                updateConnectionState(true)

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

        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Void, Error>) in

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

// MARK: - State Management

private extension WebSocketService {
    func handleFailure(_ error: Error) async {
        logger.error(
            "WebSocket failure: \(error.localizedDescription)"
        )
        
        updateConnectionState(false)
        await reconnect()
    }
    
    func reconnect() async {
        reconnectTask?.cancel()
        reconnectTask = Task {
            do {
                try await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else {
                    return
                }
                await connect()
            } catch is CancellationError {
            } catch {
                await handleFailure(error)
            }
        }
    }
    
    private func updateConnectionState(_ connected: Bool) {
        guard isConnected != connected else { return }

        isConnected = connected
        connectionContinuation.yield(connected)
    }
}

// MARK: - Utilities

private extension WebSocketService {
    func cancelTasks() {
        receiveTask?.cancel()
        pingTask?.cancel()
        reconnectTask?.cancel()

        receiveTask = nil
        pingTask = nil
        reconnectTask = nil
    }
}
