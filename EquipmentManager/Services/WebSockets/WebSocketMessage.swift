//
//  WebSocketMessage.swift
//  EquipmentManager
//
//  Created by Marek Hac on 25/05/2026.
//

import Foundation

struct WebSocketMessage: Codable, Sendable {
    let type: WebSocketMessageType
    let equipmentId: UUID
    let status: EquipmentStatus

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.type = try container.decode(WebSocketMessageType.self, forKey: .type)
        self.status = try container.decode(EquipmentStatus.self, forKey: .status)

        let equipmentId = try container.decode(String.self, forKey: .equipmentId)

        guard let uuid = UUID(uuidString: equipmentId) else {
            throw DecodingError.dataCorruptedError(
                forKey: .equipmentId,
                in: container,
                debugDescription: "Invalid UUID string: \(equipmentId)"
            )
        }

        self.equipmentId = uuid
    }
}

enum WebSocketMessageType: String, Codable {
    case update = "update"
    case heartbeat = "heartbeat"
    case error = "error"
}
