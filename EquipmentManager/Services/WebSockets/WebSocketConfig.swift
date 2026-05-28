//
//  WebSocketConfig.swift
//  EquipmentManager
//
//  Created by Marek Hac on 28/05/2026.
//

import Foundation

struct WebSocketConfig {
    let url: URL
    
    static let local = WebSocketConfig(
        url: URL(string: "ws://localhost:8080")!
    )
}
