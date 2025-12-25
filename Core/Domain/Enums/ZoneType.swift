//
//  ZoneType.swift
//  EventMonitor
//
//  Equivalent to Android ZoneType enum (used as AreaType)
//

import Foundation

enum ZoneType: String, Codable, CaseIterable {
    case seating = "SEATING"
    case standing = "STANDING"
    case vip = "VIP"
    case generalAdmission = "GENERAL_ADMISSION"
    case overflow = "OVERFLOW"
    case parking = "PARKING"
    case registration = "REGISTRATION"
    case lobby = "LOBBY"
    case outdoor = "OUTDOOR"
    case stage = "STAGE"
    case backstage = "BACKSTAGE"
    case careRoom = "CARE_ROOM"
    case foodArea = "FOOD_AREA"
    case restrooms = "RESTROOMS"
    case emergencyExit = "EMERGENCY_EXIT"
    case other = "OTHER"

    var displayName: String {
        switch self {
        case .seating: return "Seating"
        case .standing: return "Standing"
        case .vip: return "VIP"
        case .generalAdmission: return "General Admission"
        case .overflow: return "Overflow"
        case .parking: return "Parking"
        case .registration: return "Registration"
        case .lobby: return "Lobby"
        case .outdoor: return "Outdoor"
        case .stage: return "Stage"
        case .backstage: return "Backstage"
        case .careRoom: return "Care Room"
        case .foodArea: return "Food Area"
        case .restrooms: return "Restrooms"
        case .emergencyExit: return "Emergency Exit"
        case .other: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .seating: return "chair.fill"
        case .standing: return "figure.stand"
        case .vip: return "star.fill"
        case .generalAdmission: return "person.2.fill"
        case .overflow: return "arrow.up.right.square.fill"
        case .parking: return "car.fill"
        case .registration: return "checkmark.circle.fill"
        case .lobby: return "door.left.hand.open"
        case .outdoor: return "sun.max.fill"
        case .stage: return "rectangle.center.inset.filled"
        case .backstage: return "curtains.closed"
        case .careRoom: return "cross.case.fill"
        case .foodArea: return "fork.knife"
        case .restrooms: return "figure.walk"
        case .emergencyExit: return "arrow.uturn.left.square.fill"
        case .other: return "square.grid.2x2.fill"
        }
    }
}
