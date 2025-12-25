//
//  IncidentStatus.swift
//  EventMonitor
//
//  Equivalent to Android IncidentStatus enum
//

import Foundation
import SwiftUI

enum IncidentStatus: String, Codable, CaseIterable {
    case reported = "REPORTED"
    case investigating = "INVESTIGATING"
    case inProgress = "IN_PROGRESS"
    case resolved = "RESOLVED"
    case closed = "CLOSED"

    var displayName: String {
        switch self {
        case .reported: return "Reported"
        case .investigating: return "Investigating"
        case .inProgress: return "In Progress"
        case .resolved: return "Resolved"
        case .closed: return "Closed"
        }
    }

    var color: Color {
        switch self {
        case .reported: return Color(hex: "#FF7043")       // Orange
        case .investigating: return Color(hex: "#FFA726")  // Amber
        case .inProgress: return Color(hex: "#42A5F5")     // Blue
        case .resolved: return Color(hex: "#66BB6A")       // Green
        case .closed: return Color.gray
        }
    }
}
