//
//  DomainValidators.swift
//  EventMonitor
//
//  Domain-specific validators for the event monitoring app
//

import Foundation

struct DomainValidators {

    // MARK: - Venue Validation

    static func validateVenueInput(
        name: String,
        location: String,
        code: String,
        contactEmail: String? = nil,
        contactPhone: String? = nil
    ) -> Result<Void> {
        let errors = Validators.collectErrors(
            Validators.validateNotEmpty(name, "Venue name"),
            Validators.validateLength(name, "Venue name", maxLength: 100),
            Validators.validateNotEmpty(location, "Location"),
            Validators.validateLength(location, "Location", maxLength: 200),
            Validators.validateNotEmpty(code, "Venue code"),
            Validators.validateLength(code, "Venue code", minLength: 2, maxLength: 10),
            validateVenueCode(code),
            contactEmail.map { Validators.validateEmail($0, "Contact email") } ?? nil,
            contactPhone.map { Validators.validatePhone($0, "Contact phone") } ?? nil
        )

        return errors.isEmpty
            ? .success(())
            : .failure(.validationError(errors))
    }

    static func validateVenueCode(_ code: String) -> ValidationFailure? {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            return .emptyString("Venue code")
        }

        // Must be 2-10 uppercase letters or numbers
        let codeRegex = "^[A-Z0-9]{2,10}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", codeRegex)

        return predicate.evaluate(with: trimmed.uppercased())
            ? nil
            : .invalidFormat("Venue code", expectedFormat: "2-10 uppercase letters or numbers (e.g., MC, NV, DT)")
    }

    // MARK: - Event Type (Service Type) Validation

    static func validateEventTypeInput(
        name: String,
        dayType: String,
        time: String,
        description: String? = nil
    ) -> Result<Void> {
        let errors = Validators.collectErrors(
            Validators.validateNotEmpty(name, "Event type name"),
            Validators.validateLength(name, "Event type name", maxLength: 100),
            Validators.validateNotEmpty(dayType, "Day type"),
            Validators.validateLength(dayType, "Day type", maxLength: 50),
            Validators.validateNotEmpty(time, "Time"),
            Validators.validateLength(time, "Time", maxLength: 20),
            validateTimeFormat(time),
            description.map { Validators.validateLength($0, "Description", maxLength: 500) } ?? nil
        )

        return errors.isEmpty
            ? .success(())
            : .failure(.validationError(errors))
    }

    static func validateTimeFormat(_ time: String) -> ValidationFailure? {
        let trimmed = time.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            return .emptyString("Time")
        }

        // Accept formats like "9:00 AM", "09:00", "19:00"
        let timeRegex = "^([0-1]?[0-9]|2[0-3]):[0-5][0-9](\\s?(AM|PM|am|pm))?$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", timeRegex)

        return predicate.evaluate(with: trimmed)
            ? nil
            : .invalidFormat("Time", expectedFormat: "HH:MM or HH:MM AM/PM (e.g., 9:00 AM, 19:00)")
    }

    // MARK: - Area Template Validation

    static func validateAreaTemplateInput(
        name: String,
        capacity: Int,
        notes: String? = nil
    ) -> Result<Void> {
        let errors = Validators.collectErrors(
            Validators.validateNotEmpty(name, "Area name"),
            Validators.validateLength(name, "Area name", maxLength: 100),
            Validators.validatePositive(capacity, "Capacity"),
            Validators.validateRange(capacity, "Capacity", minimum: 1, maximum: 10000),
            notes.map { Validators.validateLength($0, "Notes", maxLength: 500) } ?? nil
        )

        return errors.isEmpty
            ? .success(())
            : .failure(.validationError(errors))
    }

    // MARK: - Event Validation

    static func validateEventInput(
        venueId: String,
        eventTypeId: String?,
        date: Date,
        countedBy: String,
        eventName: String? = nil,
        notes: String? = nil
    ) -> Result<Void> {
        var validations: [ValidationFailure?] = [
            Validators.validateNotEmpty(venueId, "Venue"),
            Validators.validateNotFuture(date, "Event date"),
            Validators.validateNotEmpty(countedBy, "Counter name"),
            Validators.validateLength(countedBy, "Counter name", maxLength: 100)
        ]

        if let typeId = eventTypeId {
            validations.append(Validators.validateNotEmpty(typeId, "Event type"))
        }

        if let name = eventName {
            validations.append(Validators.validateLength(name, "Event name", maxLength: 100))
        }

        if let noteText = notes {
            validations.append(Validators.validateLength(noteText, "Notes", maxLength: 1000))
        }

        let errors = Validators.collectErrors(validations)

        return errors.isEmpty
            ? .success(())
            : .failure(.validationError(errors))
    }

    // MARK: - Attendance Count Validation

    static func validateAttendanceCount(
        count: Int,
        capacity: Int
    ) -> Result<Void> {
        var validations: [ValidationFailure?] = [
            Validators.validateNonNegative(count, "Count"),
            Validators.validateRange(count, "Count", maximum: 99999),
            Validators.validatePositive(capacity, "Capacity")
        ]

        // Warning if count exceeds capacity (not an error, just informational)
        if count > capacity {
            validations.append(.custom("Count", "Count (\(count)) exceeds capacity (\(capacity))"))
        }

        let errors = Validators.collectErrors(validations)

        return errors.isEmpty
            ? .success(())
            : .failure(.validationError(errors))
    }

    // MARK: - Report Date Range Validation

    static func validateReportDateRange(
        startDate: Date,
        endDate: Date
    ) -> Result<Void> {
        let oneYearInSeconds: TimeInterval = 365 * 24 * 60 * 60

        var validations: [ValidationFailure?] = [
            Validators.validateNotFuture(startDate, "Start date"),
            Validators.validateNotFuture(endDate, "End date"),
            Validators.validateDateRange(startDate: startDate, endDate: endDate, "Date range")
        ]

        // Validate range is not too large (e.g., max 1 year)
        if endDate.timeIntervalSince(startDate) > oneYearInSeconds {
            validations.append(.custom("Date range", "Date range cannot exceed 1 year"))
        }

        let errors = Validators.collectErrors(validations)

        return errors.isEmpty
            ? .success(())
            : .failure(.validationError(errors))
    }

    // MARK: - Manual Count Edit Validation

    static func validateManualCountEdit(
        newCount: Int,
        capacity: Int,
        isLocked: Bool
    ) -> Result<Void> {
        if isLocked {
            return .failure(.locked("Cannot edit count for locked event"))
        }

        return validateAttendanceCount(count: newCount, capacity: capacity)
    }

    // MARK: - Lost Item Validation

    static func validateLostItemInput(
        description: String,
        foundZone: String,
        notes: String? = nil
    ) -> Result<Void> {
        let errors = Validators.collectErrors(
            Validators.validateNotEmpty(description, "Item description"),
            Validators.validateLength(description, "Item description", maxLength: 500),
            Validators.validateNotEmpty(foundZone, "Found zone"),
            Validators.validateLength(foundZone, "Found zone", maxLength: 100),
            notes.map { Validators.validateLength($0, "Notes", maxLength: 1000) } ?? nil
        )

        return errors.isEmpty
            ? .success(())
            : .failure(.validationError(errors))
    }

    // MARK: - Incident Validation

    static func validateIncidentInput(
        title: String,
        description: String,
        location: String,
        notes: String? = nil
    ) -> Result<Void> {
        let errors = Validators.collectErrors(
            Validators.validateNotEmpty(title, "Incident title"),
            Validators.validateLength(title, "Incident title", maxLength: 200),
            Validators.validateNotEmpty(description, "Incident description"),
            Validators.validateLength(description, "Incident description", maxLength: 2000),
            Validators.validateNotEmpty(location, "Location"),
            Validators.validateLength(location, "Location", maxLength: 200),
            notes.map { Validators.validateLength($0, "Notes", maxLength: 1000) } ?? nil
        )

        return errors.isEmpty
            ? .success(())
            : .failure(.validationError(errors))
    }
}
