//
//  MockEquipment.swift
//  EquipmentManager
//
//  Created by Marek Hac on 25/05/2026.
//

import Foundation

// MARK: - Mock Repository

actor MockEquipment: EquipmentProtocol {
    private let equipment: [Equipment] = [
                
        Equipment(
            // this one has a UUID configured on a WebSocket server
            
            id: UUID(uuidString: "550e8400-e29b-41d4-a716-446655440000") ?? UUID(),
            name: "Injection Molder #1",
            status: .producing,
            lastUpdated: .now
        ),

        Equipment(
            id: UUID(),
            name: "Injection Molder #2",
            status: .stopped,
            lastUpdated: .now
        ),

        Equipment(
            id: UUID(),
            name: "Assembly Robot #1",
            status: .startup,
            lastUpdated: .now
        )
    ]
    
    func fetchEquipment()  -> [Equipment] {
        return equipment
    }
}
