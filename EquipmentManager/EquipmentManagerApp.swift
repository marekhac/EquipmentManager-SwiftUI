//
//  EquipmentManagerApp.swift
//  EquipmentManager
//
//  Created by Marek Hac on 25/05/2026.
//

import SwiftUI

@main
struct EquipmentManagerApp: App {
    var body: some Scene {
        WindowGroup {
            DeviceStatusView(viewModel: DeviceStatusViewModel(
                repository: MockEquipment(),
                webSocketService: WebSocketService()
            ))
        }
    }
}
