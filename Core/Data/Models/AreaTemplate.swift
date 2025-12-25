//
//  AreaTemplate.swift
//  EventMonitor
//
//  Equivalent to Android AreaTemplateEntity
//

import Foundation
import SwiftData

@Model
final class AreaTemplate {
    @Attribute(.unique) var id: String
    var name: String
    var type: ZoneType
    var capacity: Int
    var displayOrder: Int
    var color: String  // Hex color string
    var icon: String
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date

    // Cloud sync fields
    var isSyncedToCloud: Bool
    var cloudId: String?

    // Relationships
    var venue: Venue?

    @Relationship(deleteRule: .cascade, inverse: \AreaCount.areaTemplate)
    var areaCounts: [AreaCount]

    init(
        id: String = UUID().uuidString,
        name: String,
        type: ZoneType = .generalAdmission,
        capacity: Int = 0,
        displayOrder: Int = 0,
        color: String = "#2196F3",
        icon: String = "person.2.fill",
        isActive: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isSyncedToCloud: Bool = false,
        cloudId: String? = nil,
        venue: Venue? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.capacity = capacity
        self.displayOrder = displayOrder
        self.color = color
        self.icon = icon
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isSyncedToCloud = isSyncedToCloud
        self.cloudId = cloudId
        self.venue = venue
        self.areaCounts = []
    }
}
