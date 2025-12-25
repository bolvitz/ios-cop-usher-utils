//
//  LostItem.swift
//  EventMonitor
//
//  Equivalent to Android LostItemEntity
//

import Foundation
import SwiftData

@Model
final class LostItem {
    @Attribute(.unique) var id: String
    var itemDescription: String  // 'description' is a reserved keyword
    var category: ItemCategory
    var foundZone: String
    var foundDate: Date
    var photoUri: String
    var color: String
    var brand: String
    var identifyingMarks: String
    var status: ItemStatus
    var claimedBy: String
    var claimedDate: Date?
    var claimerContact: String
    var verificationNotes: String
    var reportedBy: String
    var notes: String
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
        itemDescription: String,
        category: ItemCategory = .other,
        foundZone: String = "",
        foundDate: Date = Date(),
        photoUri: String = "",
        color: String = "",
        brand: String = "",
        identifyingMarks: String = "",
        status: ItemStatus = .pending,
        claimedBy: String = "",
        claimedDate: Date? = nil,
        claimerContact: String = "",
        verificationNotes: String = "",
        reportedBy: String = "",
        notes: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isSyncedToCloud: Bool = false,
        cloudId: String? = nil,
        venue: Venue? = nil,
        event: Event? = nil
    ) {
        self.id = id
        self.itemDescription = itemDescription
        self.category = category
        self.foundZone = foundZone
        self.foundDate = foundDate
        self.photoUri = photoUri
        self.color = color
        self.brand = brand
        self.identifyingMarks = identifyingMarks
        self.status = status
        self.claimedBy = claimedBy
        self.claimedDate = claimedDate
        self.claimerContact = claimerContact
        self.verificationNotes = verificationNotes
        self.reportedBy = reportedBy
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isSyncedToCloud = isSyncedToCloud
        self.cloudId = cloudId
        self.venue = venue
        self.event = event
    }

    // Business logic: 180-day donation rule
    var daysUntilDonation: Int {
        let calendar = Calendar.current
        let daysSinceFound = calendar.dateComponents([.day], from: foundDate, to: Date()).day ?? 0
        return max(0, 180 - daysSinceFound)
    }

    var canBeDonated: Bool {
        return daysUntilDonation == 0 && status == .pending
    }
}
