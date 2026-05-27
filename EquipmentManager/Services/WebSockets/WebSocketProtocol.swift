//
//  WebSocketProtocol.swift
//  EquipmentManager
//
//  Created by Marek Hac on 26/05/2026.
//

import Foundation

protocol WebSocketProtocol: Sendable {
    var isConnected: Bool { get }
    var events: AsyncStream<StatusUpdateEvent> { get }

    func connect() async
    func disconnect()
}
