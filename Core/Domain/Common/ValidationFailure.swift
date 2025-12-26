//
//  ValidationFailure.swift
//  EventMonitor
//
//  Represents different types of validation failures
//

import Foundation

enum ValidationFailure: Equatable {
    case emptyString(String)  // field name
    case invalidLength(String, min: Int?, max: Int?)  // field name, min, max
    case invalidFormat(String, expectedFormat: String)  // field name, format description
    case invalidRange(String, min: Int?, max: Int?)  // field name, min, max
    case notPositive(String)  // field name
    case notNonNegative(String)  // field name
    case futureDate(String)  // field name
    case invalidDateRange(String)  // field name
    case custom(String, String)  // field name, message

    var message: String {
        switch self {
        case .emptyString(let field):
            return "\(field) cannot be empty"
        case .invalidLength(let field, let min, let max):
            if let min = min, let max = max {
                return "\(field) must be between \(min) and \(max) characters"
            } else if let min = min {
                return "\(field) must be at least \(min) characters"
            } else if let max = max {
                return "\(field) must be at most \(max) characters"
            }
            return "\(field) has invalid length"
        case .invalidFormat(let field, let format):
            return "\(field) must be in format: \(format)"
        case .invalidRange(let field, let min, let max):
            if let min = min, let max = max {
                return "\(field) must be between \(min) and \(max)"
            } else if let min = min {
                return "\(field) must be at least \(min)"
            } else if let max = max {
                return "\(field) must be at most \(max)"
            }
            return "\(field) is out of range"
        case .notPositive(let field):
            return "\(field) must be positive"
        case .notNonNegative(let field):
            return "\(field) cannot be negative"
        case .futureDate(let field):
            return "\(field) cannot be in the future"
        case .invalidDateRange(let field):
            return "\(field): end date must be after start date"
        case .custom(let field, let message):
            return "\(field): \(message)"
        }
    }
}
