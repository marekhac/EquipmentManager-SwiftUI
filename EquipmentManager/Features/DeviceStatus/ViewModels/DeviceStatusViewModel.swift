//
//  DeviceStatusViewModel.swift
//  EquipmentManager
//
//  Created by Marek Hac on 25/05/2026.
//

import Combine
import Foundation

@MainActor
final class DeviceStatusViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var equipments: [Equipment] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isConnected = false
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let equipmentService: EquipmentProtocol
    private let webSocketService: WebSocketProtocol

    // MARK: - Tasks

    private var loadTask: Task<Void, Never>?
    private var socketTask: Task<Void, Never>?
    private var connectionMonitorTask: Task<Void, Never>?

    // MARK: - Init

    init(repository: EquipmentProtocol, webSocketService: WebSocketProtocol) {
        self.equipmentService = repository
        self.webSocketService = webSocketService
    }
}

// MARK: - Handling WebSocket connection

extension DeviceStatusViewModel {
    func prepareForDisplay() async {
        await loadEquipment()
        startSocket()
    }
    
    func startSocket() {
        socketTask?.cancel()
        socketTask = Task {
            await webSocketService.connect()
            
            monitorConnection()
            
            for await event in webSocketService.events {
                apply(event)
            }
        }
    }

    func cleanUp() {
        socketTask?.cancel()
        connectionMonitorTask?.cancel()
        webSocketService.disconnect()
    }
    
    private func monitorConnection() {
        connectionMonitorTask?.cancel()

        connectionMonitorTask = Task {
            while !Task.isCancelled {
                isConnected = webSocketService.isConnected
                try? await Task.sleep(for: .seconds(1))
            }
        }
    }
}

// MARK: - Fetch/update equipment

extension DeviceStatusViewModel {
    func loadEquipment() async {
        loadTask?.cancel()

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            equipments = try await equipmentService.fetchEquipment()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func apply(_ event: StatusUpdateEvent) {
        guard let index = equipments.firstIndex(where: { $0.id == event.equipmentId }) else {
            return
        }
        equipments[index].status = event.status
        equipments[index].lastUpdated = event.timestamp
                
        print("[UPDATED] \(equipments[index].name) → \(event.status)")
    }
}
