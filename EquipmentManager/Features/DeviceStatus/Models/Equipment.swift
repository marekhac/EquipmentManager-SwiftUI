//
//  Equipment.swift
//  EquipmentManager
//
//  Created by Marek Hac on 25/05/2026.
//

import Foundation

struct Equipment: Identifiable, Codable {
    let id: UUID
    let name: String
    
    var status: EquipmentStatus
    var lastUpdated: Date
}
