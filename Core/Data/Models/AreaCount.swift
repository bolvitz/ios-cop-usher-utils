//
//  AreaCount.swift
//  EventMonitor
//
//  Equivalent to Android AreaCountEntity
//

import Foundation
import SwiftData

@Model
final class AreaCount {
    @Attribute(.unique) var id: String
    var count: Int
    var capacity: Int  // Snapshot from template at event creation
    var countHistory: String  // JSON for undo/redo functionality
    var notes: String
    var createdAt: Date
    var updatedAt: Date

    // Cloud sync fields
    var isSyncedToCloud: Bool
    var cloudId: String?

    // Relationships
    var event: Event?
    var areaTemplate: AreaTemplate?

    init(
        id: String = UUID().uuidString,
        count: Int = 0,
        capacity: Int = 0,
        countHistory: String = "[]",
        notes: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isSyncedToCloud: Bool = false,
        cloudId: String? = nil,
        event: Event? = nil,
        areaTemplate: AreaTemplate? = nil
    ) {
        self.id = id
        self.count = count
        self.capacity = capacity
        self.countHistory = countHistory
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isSyncedToCloud = isSyncedToCloud
        self.cloudId = cloudId
        self.event = event
        self.areaTemplate = areaTemplate
    }

    // Undo/Redo support
    func getHistory() -> [Int] {
        guard let data = countHistory.data(using: .utf8),
              let history = try? JSONDecoder().decode([Int].self, from: data) else {
            return []
        }
        return history
    }

    func addToHistory(_ value: Int) {
        var history = getHistory()
        history.append(value)
        if let data = try? JSONEncoder().encode(history),
           let json = String(data: data, encoding: .utf8) {
            countHistory = json
        }
    }

    func clearHistory() {
        countHistory = "[]"
    }
}
