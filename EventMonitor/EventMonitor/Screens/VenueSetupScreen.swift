//
//  VenueSetupScreen.swift
//  EventMonitor
//
//  Screen for creating/editing venues
//  Equivalent to Android VenueSetupScreen.kt
//

import SwiftUI
import SwiftData

struct VenueSetupScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let venue: Venue?

    @State private var name = ""
    @State private var location = ""
    @State private var code = ""
    @State private var color = "#6200EE"
    @State private var contactPerson = ""
    @State private var contactPhone = ""
    @State private var contactEmail = ""
    @State private var isHeadCountEnabled = true
    @State private var isLostAndFoundEnabled = true
    @State private var isIncidentReportingEnabled = true
    @State private var showingAreaManagement = false
    @State private var showingError = false
    @State private var errorMessage = ""

    private var isEditing: Bool {
        venue != nil
    }

    var body: some View {
        Form {
            Section("Venue Details") {
                TextField("Venue Name", text: $name)
                TextField("Location", text: $location)
                TextField("Venue Code (Uppercase)", text: $code)
                    .textInputAutocapitalization(.characters)
                    .onChange(of: code) { oldValue, newValue in
                        code = newValue.uppercased()
                    }
            }

            Section("Contact Information") {
                TextField("Contact Person", text: $contactPerson)
                TextField("Phone", text: $contactPhone)
                    .keyboardType(.phonePad)
                TextField("Email", text: $contactEmail)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
            }

            Section("Features") {
                Toggle("Head Count", isOn: $isHeadCountEnabled)
                Toggle("Lost & Found", isOn: $isLostAndFoundEnabled)
                Toggle("Incident Reporting", isOn: $isIncidentReportingEnabled)
            }

            Section("Appearance") {
                ColorPicker("Venue Color", selection: Binding(
                    get: { Color(hex: color) },
                    set: { color = $0.toHex() }
                ))
            }

            if isEditing {
                Section {
                    Button {
                        showingAreaManagement = true
                    } label: {
                        HStack {
                            Text("Manage Areas")
                            Spacer()
                            if let venue = venue {
                                Text("\(venue.areas.count) areas")
                                    .foregroundColor(.gray)
                            }
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .navigationTitle(isEditing ? "Edit Venue" : "New Venue")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveVenue()
                }
                .disabled(name.isEmpty || location.isEmpty || code.isEmpty)
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showingAreaManagement) {
            if let venue = venue {
                NavigationStack {
                    AreaManagementScreen(venue: venue)
                }
            }
        }
        .onAppear {
            loadVenue()
        }
    }

    private func loadVenue() {
        guard let venue = venue else { return }
        name = venue.name
        location = venue.location
        code = venue.code
        color = venue.color
        contactPerson = venue.contactPerson
        contactPhone = venue.contactPhone
        contactEmail = venue.contactEmail
        isHeadCountEnabled = venue.isHeadCountEnabled
        isLostAndFoundEnabled = venue.isLostAndFoundEnabled
        isIncidentReportingEnabled = venue.isIncidentReportingEnabled
    }

    private func saveVenue() {
        // Validate input
        let validationResult = DomainValidators.validateVenueInput(
            name: name,
            location: location,
            code: code,
            contactEmail: contactEmail.isEmpty ? nil : contactEmail,
            contactPhone: contactPhone.isEmpty ? nil : contactPhone
        )

        if case .failure(let error) = validationResult {
            errorMessage = error.message
            showingError = true
            return
        }

        // Validate code uniqueness
        let venueId = venue?.id ?? ""
        let descriptor = FetchDescriptor<Venue>(
            predicate: #Predicate { $0.code == code.uppercased() && $0.id != venueId }
        )
        if let existingVenues = try? modelContext.fetch(descriptor), !existingVenues.isEmpty {
            errorMessage = "A venue with code '\(code.uppercased())' already exists"
            showingError = true
            return
        }

        if let venue = venue {
            // Update existing
            venue.name = name
            venue.location = location
            venue.code = code.uppercased()
            venue.color = color
            venue.contactPerson = contactPerson
            venue.contactPhone = contactPhone
            venue.contactEmail = contactEmail
            venue.isHeadCountEnabled = isHeadCountEnabled
            venue.isLostAndFoundEnabled = isLostAndFoundEnabled
            venue.isIncidentReportingEnabled = isIncidentReportingEnabled
            venue.updatedAt = Date()
        } else {
            // Create new
            let newVenue = Venue(
                name: name,
                location: location,
                code: code.uppercased(),
                color: color,
                contactPerson: contactPerson,
                contactPhone: contactPhone,
                contactEmail: contactEmail,
                isHeadCountEnabled: isHeadCountEnabled,
                isLostAndFoundEnabled: isLostAndFoundEnabled,
                isIncidentReportingEnabled: isIncidentReportingEnabled
            )
            modelContext.insert(newVenue)
        }

        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to save venue: \(error.localizedDescription)"
            showingError = true
        }
    }
}

#Preview {
    NavigationStack {
        VenueSetupScreen(venue: nil)
            .modelContainer(for: Venue.self)
    }
}
