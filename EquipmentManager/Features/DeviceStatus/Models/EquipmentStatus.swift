//
//  EquipmentStatus.swift
//  EquipmentManager
//
//  Created by Marek Hac on 25/05/2026.
//

import Foundation
import SwiftUI

enum EquipmentStatus: String, Codable, CaseIterable {
    case stopped = "STOPPED"
    case startup = "STARTUP"
    case producing = "PRODUCING"
}

extension EquipmentStatus {
    var color: Color {
        switch self {
        case .stopped:
            return .red
        case .startup:
            return .orange
        case .producing:
            return .green
        }
    }

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
