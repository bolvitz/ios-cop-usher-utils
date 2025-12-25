//
//  Venue.swift
//  EventMonitor
//
//  Equivalent to Android VenueEntity
//

import Foundation
import SwiftData

@Model
final class Venue {
    @Attribute(.unique) var id: String
    var name: String
    var location: String
    @Attribute(.unique) var code: String  // Unique uppercase code
    var color: String  // Hex color string
    var contactPerson: String
    var contactPhone: String
    var contactEmail: String
    var isActive: Bool
    var isHeadCountEnabled: Bool
    var isLostAndFoundEnabled: Bool
    var isIncidentReportingEnabled: Bool
    var createdAt: Date
    var updatedAt: Date

    // Cloud sync fields (for future use)
    var isSyncedToCloud: Bool
    var cloudId: String?

    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \AreaTemplate.venue)
    var areas: [AreaTemplate]

    @Relationship(deleteRule: .cascade, inverse: \Event.venue)
    var events: [Event]

    @Relationship(deleteRule: .cascade, inverse: \LostItem.venue)
    var lostItems: [LostItem]

    @Relationship(deleteRule: .cascade, inverse: \Incident.venue)
    var incidents: [Incident]

    init(
        id: String = UUID().uuidString,
        name: String,
        location: String,
        code: String,
        color: String = "#6200EE",
        contactPerson: String = "",
        contactPhone: String = "",
        contactEmail: String = "",
        isActive: Bool = true,
        isHeadCountEnabled: Bool = true,
        isLostAndFoundEnabled: Bool = true,
        isIncidentReportingEnabled: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isSyncedToCloud: Bool = false,
        cloudId: String? = nil
    ) {
        self.id = id
        self.name = name
        self.location = location
        self.code = code.uppercased()
        self.color = color
        self.contactPerson = contactPerson
        self.contactPhone = contactPhone
        self.contactEmail = contactEmail
        self.isActive = isActive
        self.isHeadCountEnabled = isHeadCountEnabled
        self.isLostAndFoundEnabled = isLostAndFoundEnabled
        self.isIncidentReportingEnabled = isIncidentReportingEnabled
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isSyncedToCloud = isSyncedToCloud
        self.cloudId = cloudId
        self.areas = []
        self.events = []
        self.lostItems = []
        self.incidents = []
    }
}
