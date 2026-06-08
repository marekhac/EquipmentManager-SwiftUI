//
//  EquipmentStatus.swift
//  EquipmentManager
//
//  Created by Marek Hac on 25/05/2026.
//

import Foundation

enum EquipmentStatus: String, Codable, Sendable {
    case stopped = "STOPPED"
    case startup = "STARTUP"
    case producing = "PRODUCING"
}

extension EquipmentStatus {
    var icon: String {
        switch self {
        case .stopped:
            return "stop.fill"
        case .startup:
            return "clock.fill"
        case .producing:
            return "play.fill"
        }
    }
}
