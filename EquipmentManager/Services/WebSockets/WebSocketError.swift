//
//  WebSocketError.swift
//  EquipmentManager
//
//  Created by Marek Hac on 25/05/2026.
//

import Foundation

enum WebSocketError: LocalizedError {
    case invalidUTF8
    case unknownMessageType
    case notConnected
    case malformedMessage(Error)

    var errorDescription: String? {
        switch self {
        case .invalidUTF8:
            return "Invalid UTF-8 message"

        case .unknownMessageType:
            return "Unknown websocket message type"

        case .notConnected:
            return "WebSocket is not connected"

        case .malformedMessage(let error):
            return "Dropping malformed message: \(error.localizedDescription)"
        }
    }
}
