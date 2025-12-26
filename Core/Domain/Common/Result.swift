//
//  Result.swift
//  EventMonitor
//
//  Result type for operations that can fail
//

import Foundation

enum Result<T> {
    case success(T)
    case failure(AppError)

    var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }

    var isFailure: Bool {
        !isSuccess
    }

    var value: T? {
        if case .success(let value) = self {
            return value
        }
        return nil
    }

    var error: AppError? {
        if case .failure(let error) = self {
            return error
        }
        return nil
    }
}
