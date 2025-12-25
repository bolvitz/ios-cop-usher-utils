//
//  IncidentSeverity.swift
//  EventMonitor
//
//  Equivalent to Android IncidentSeverity enum
//

import Foundation
import SwiftUI

enum IncidentSeverity: String, Codable, CaseIterable {
    case low = "LOW"
    case medium = "MEDIUM"
    case high = "HIGH"
    case critical = "CRITICAL"

    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .critical: return "Critical"
        }
    }

    var color: Color {
        switch self {
        case .low: return Color(hex: "#66BB6A")       // Green
        case .medium: return Color(hex: "#FFA726")    // Orange
        case .high: return Color(hex: "#FF7043")      // Deep Orange
        case .critical: return Color(hex: "#EF5350")  // Red
        }
    }

    var icon: String {
        switch self {
        case .low: return "info.circle"
        case .medium: return "exclamationmark.triangle"
        case .high: return "exclamationmark.triangle.fill"
        case .critical: return "exclamationmark.octagon.fill"
        }
    }
}
