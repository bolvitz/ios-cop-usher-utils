//
//  AppError.swift
//  EventMonitor
//
//  Application-level errors
//

import Foundation

enum AppError: Error, Equatable {
    case validationError([ValidationFailure])
    case alreadyExists(entity: String, field: String, value: String)
    case notFound(entity: String, id: String)
    case locked(String)  // message
    case databaseError(String)  // message
    case unknown(String)  // message

    var message: String {
        switch self {
        case .validationError(let failures):
            return failures.map { $0.message }.joined(separator: "\n")
        case .alreadyExists(let entity, let field, let value):
            return "\(entity) with \(field) '\(value)' already exists"
        case .notFound(let entity, let id):
            return "\(entity) with id '\(id)' not found"
        case .locked(let message):
            return message
        case .databaseError(let message):
            return "Database error: \(message)"
        case .unknown(let message):
            return message
        }
    }
}
