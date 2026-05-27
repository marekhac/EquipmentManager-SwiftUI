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

    enum CodingKeys: String, CodingKey {
        case type
        case equipmentId
        case status
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.type = try container.decode(WebSocketMessageType.self, forKey: .type)
        self.status = try container.decode(EquipmentStatus.self, forKey: .status)

        let idString = try container.decode(String.self, forKey: .equipmentId)

        guard let uuid = UUID(uuidString: idString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .equipmentId,
                in: container,
                debugDescription: "Invalid UUID string: \(idString)"
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
