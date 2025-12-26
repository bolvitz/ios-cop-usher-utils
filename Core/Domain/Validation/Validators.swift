//
//  Validators.swift
//  EventMonitor
//
//  Validation utilities for common input validation patterns
//

import Foundation

struct Validators {

    // MARK: - String Validation

    static func validateNotEmpty(_ value: String, _ fieldName: String) -> ValidationFailure? {
        return value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? .emptyString(fieldName)
            : nil
    }

    static func validateLength(
        _ value: String,
        _ fieldName: String,
        minLength: Int? = nil,
        maxLength: Int? = nil
    ) -> ValidationFailure? {
        let length = value.count

        if let min = minLength, length < min {
            return .invalidLength(fieldName, min: min, max: maxLength)
        }

        if let max = maxLength, length > max {
            return .invalidLength(fieldName, min: minLength, max: max)
        }

        return nil
    }

    // MARK: - Number Validation

    static func validatePositive(_ value: Int, _ fieldName: String) -> ValidationFailure? {
        if value < 0 {
            return .notNonNegative(fieldName)
        }
        if value == 0 {
            return .notPositive(fieldName)
        }
        return nil
    }

    static func validateNonNegative(_ value: Int, _ fieldName: String) -> ValidationFailure? {
        return value < 0 ? .notNonNegative(fieldName) : nil
    }

    static func validateRange(
        _ value: Int,
        _ fieldName: String,
        minimum: Int? = nil,
        maximum: Int? = nil
    ) -> ValidationFailure? {
        if let min = minimum, value < min {
            return .invalidRange(fieldName, min: min, max: maximum)
        }

        if let max = maximum, value > max {
            return .invalidRange(fieldName, min: minimum, max: max)
        }

        return nil
    }

    // MARK: - Date Validation

    static func validateNotFuture(_ date: Date, _ fieldName: String) -> ValidationFailure? {
        return date > Date() ? .futureDate(fieldName) : nil
    }

    static func validateNotPast(_ date: Date, _ fieldName: String) -> ValidationFailure? {
        return date < Date() ? .custom(fieldName, "cannot be in the past") : nil
    }

    static func validateDateRange(
        startDate: Date,
        endDate: Date,
        _ fieldName: String = "Date range"
    ) -> ValidationFailure? {
        return startDate > endDate ? .invalidDateRange(fieldName) : nil
    }

    // MARK: - Format Validation

    static func validateEmail(_ email: String, _ fieldName: String = "Email") -> ValidationFailure? {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return nil  // Allow empty emails (optional field)
        }

        let emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)

        return predicate.evaluate(with: trimmed)
            ? nil
            : .invalidFormat(fieldName, expectedFormat: "valid email address")
    }

    static func validatePhone(_ phone: String, _ fieldName: String = "Phone") -> ValidationFailure? {
        let trimmed = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return nil  // Allow empty phones (optional field)
        }

        // Allow common formats: (123) 456-7890, 123-456-7890, 1234567890, +1-234-567-8900
        let phoneRegex = "^[+]?[(]?[0-9]{1,4}[)]?[-\\s\\.]?[(]?[0-9]{1,4}[)]?[-\\s\\.]?[0-9]{1,9}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)

        return predicate.evaluate(with: trimmed)
            ? nil
            : .invalidFormat(fieldName, expectedFormat: "valid phone number")
    }

    // MARK: - Collection Helpers

    static func collectErrors(_ validators: ValidationFailure?...) -> [ValidationFailure] {
        return validators.compactMap { $0 }
    }

    static func collectErrors(_ validators: [ValidationFailure?]) -> [ValidationFailure] {
        return validators.compactMap { $0 }
    }
}
