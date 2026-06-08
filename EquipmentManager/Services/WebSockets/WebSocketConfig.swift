//
//  WebSocketConfig.swift
//  EquipmentManager
//
//  Created by Marek Hac on 28/05/2026.
//

import Foundation

struct WebSocketConfig: Sendable {
    let url: URL
        
    nonisolated static let local = WebSocketConfig(
        url: URL(string: "ws://localhost:8080")!
    )
}
