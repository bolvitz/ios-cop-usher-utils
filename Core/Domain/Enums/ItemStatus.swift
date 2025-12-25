//
//  ItemStatus.swift
//  EventMonitor
//
//  Equivalent to Android ItemStatus enum
//

import Foundation

enum ItemStatus: String, Codable, CaseIterable {
    case pending = "PENDING"
    case claimed = "CLAIMED"
    case donated = "DONATED"
    case disposed = "DISPOSED"

    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .claimed: return "Claimed"
        case .donated: return "Donated"
        case .disposed: return "Disposed"
        }
    }

    var color: String {
        switch self {
        case .pending: return "#FFA726"      // Orange
        case .claimed: return "#66BB6A"      // Green
        case .donated: return "#42A5F5"      // Blue
        case .disposed: return "#EF5350"     // Red
        }
    }
}
