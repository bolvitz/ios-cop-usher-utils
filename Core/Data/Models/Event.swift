//
//  Event.swift
//  EventMonitor
//
//  Equivalent to Android EventEntity
//

import Foundation
import SwiftData

@Model
final class Event {
    @Attribute(.unique) var id: String
    var date: Date
    var eventName: String
    var totalAttendance: Int
    var totalCapacity: Int
    var countedBy: String
    var countedByUserId: String
    var isLocked: Bool
    var notes: String
    var weather: String
    var createdAt: Date
    var updatedAt: Date

    // Cloud sync fields
    var isSyncedToCloud: Bool
    var cloudId: String?

    // Relationships
    var venue: Venue?
    var eventType: EventType?

    @Relationship(deleteRule: .cascade, inverse: \AreaCount.event)
    var areaCounts: [AreaCount]

    @Relationship(deleteRule: .nullify, inverse: \LostItem.event)
    var lostItems: [LostItem]

    @Relationship(deleteRule: .nullify, inverse: \Incident.event)
    var incidents: [Incident]

    init(
        id: String = UUID().uuidString,
        date: Date = Date(),
        eventName: String = "",
        totalAttendance: Int = 0,
        totalCapacity: Int = 0,
        countedBy: String = "",
        countedByUserId: String = "",
        isLocked: Bool = false,
        notes: String = "",
        weather: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isSyncedToCloud: Bool = false,
        cloudId: String? = nil,
        venue: Venue? = nil,
        eventType: EventType? = nil
    ) {
        self.id = id
        self.date = date
        self.eventName = eventName
        self.totalAttendance = totalAttendance
        self.totalCapacity = totalCapacity
        self.countedBy = countedBy
        self.countedByUserId = countedByUserId
        self.isLocked = isLocked
        self.notes = notes
        self.weather = weather
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isSyncedToCloud = isSyncedToCloud
        self.cloudId = cloudId
        self.venue = venue
        self.eventType = eventType
        self.areaCounts = []
        self.lostItems = []
        self.incidents = []
    }
}
