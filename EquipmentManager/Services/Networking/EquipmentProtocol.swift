//
//  EquipmentProtocol.swift
//  EquipmentManager
//
//  Created by Marek Hac on 27/05/2026.
//

protocol EquipmentProtocol: Sendable {
    func fetchEquipment() async throws -> [Equipment]
}
