//
//  Incident.swift
//  EventMonitor
//
//  Equivalent to Android IncidentEntity
//

import Foundation
import SwiftData

@Model
final class Incident {
    @Attribute(.unique) var id: String
    var title: String
    var incidentDescription: String  // 'description' is a reserved keyword
    var severity: IncidentSeverity
    var status: IncidentStatus
    var category: String
    var location: String
    var photoUri: String
    var reportedBy: String
    var assignedTo: String
    var reportedAt: Date
    var resolvedAt: Date?
    var notes: String
    var actionsTaken: String
    var createdAt: Date
    var updatedAt: Date

    // Cloud sync fields
    var isSyncedToCloud: Bool
    var cloudId: String?

    // Relationships
    var venue: Venue?
    var event: Event?

    init(
        id: String = UUID().uuidString,
        title: String,
        incidentDescription: String,
        severity: IncidentSeverity = .low,
        status: IncidentStatus = .reported,
        category: String = "",
        location: String = "",
        photoUri: String = "",
        reportedBy: String = "",
        assignedTo: String = "",
        reportedAt: Date = Date(),
        resolvedAt: Date? = nil,
        notes: String = "",
        actionsTaken: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isSyncedToCloud: Bool = false,
        cloudId: String? = nil,
        venue: Venue? = nil,
        event: Event? = nil
    ) {
        self.id = id
        self.title = title
        self.incidentDescription = incidentDescription
        self.severity = severity
        self.status = status
        self.category = category
        self.location = location
        self.photoUri = photoUri
        self.reportedBy = reportedBy
        self.assignedTo = assignedTo
        self.reportedAt = reportedAt
        self.resolvedAt = resolvedAt
        self.notes = notes
        self.actionsTaken = actionsTaken
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isSyncedToCloud = isSyncedToCloud
        self.cloudId = cloudId
        self.venue = venue
        self.event = event
    }
}
