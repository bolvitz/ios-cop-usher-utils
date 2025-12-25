//
//  EventType.swift
//  EventMonitor
//
//  Equivalent to Android EventTypeEntity
//

import Foundation
import SwiftData

@Model
final class EventType {
    @Attribute(.unique) var id: String
    @Attribute(.unique) var name: String
    var dayType: String  // e.g., "Sunday", "Wednesday"
    var time: String     // e.g., "9:00 AM"
    var description: String
    var displayOrder: Int
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date

    // Cloud sync fields
    var isSyncedToCloud: Bool
    var cloudId: String?

    // Relationships
    @Relationship(deleteRule: .nullify, inverse: \Event.eventType)
    var events: [Event]

    init(
        id: String = UUID().uuidString,
        name: String,
        dayType: String = "",
        time: String = "",
        description: String = "",
        displayOrder: Int = 0,
        isActive: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isSyncedToCloud: Bool = false,
        cloudId: String? = nil
    ) {
        self.id = id
        self.name = name
        self.dayType = dayType
        self.time = time
        self.description = description
        self.displayOrder = displayOrder
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isSyncedToCloud = isSyncedToCloud
        self.cloudId = cloudId
        self.events = []
    }
}
