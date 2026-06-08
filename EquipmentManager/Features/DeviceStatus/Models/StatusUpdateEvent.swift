//
//  StatusUpdateEvent.swift
//  EquipmentManager
//
//  Created by Marek Hac on 25/05/2026.
//

import Foundation

struct StatusUpdateEvent: Identifiable, Sendable {
    let id = UUID()
    let equipmentId: UUID
    let status: EquipmentStatus
    let timestamp: Date

    nonisolated init(equipmentId: UUID, status: EquipmentStatus, timestamp: Date = .now) {
        self.equipmentId = equipmentId
        self.status = status
        self.timestamp = timestamp
    }
}
