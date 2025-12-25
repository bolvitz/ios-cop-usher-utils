//
//  AddEditIncidentScreen.swift
//  EventMonitor
//
//  Screen for adding/editing incidents
//  Equivalent to Android AddEditIncidentScreen.kt
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddEditIncidentScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var events: [Event]

    let venue: Venue
    let incident: Incident?

    @State private var title = ""
    @State private var incidentDescription = ""
    @State private var severity: IncidentSeverity = .low
    @State private var status: IncidentStatus = .reported
    @State private var category = ""
    @State private var location = ""
    @State private var reportedBy = ""
    @State private var assignedTo = ""
    @State private var notes = ""
    @State private var actionsTaken = ""
    @State private var selectedEvent: Event?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoUri = ""

    private var isEditing: Bool {
        incident != nil
    }

    private var venueEvents: [Event] {
        events.filter { $0.venue?.id == venue.id }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Incident Details") {
                    TextField("Title", text: $title)

                    TextField("Description", text: $incidentDescription, axis: .vertical)
                        .lineLimit(4...8)

                    Picker("Severity", selection: $severity) {
                        ForEach(IncidentSeverity.allCases, id: \.self) { sev in
                            HStack {
                                Image(systemName: sev.icon)
                                    .foregroundColor(sev.color)
                                Text(sev.displayName)
                            }
                            .tag(sev)
                        }
                    }

                    if isEditing {
                        Picker("Status", selection: $status) {
                            ForEach(IncidentStatus.allCases, id: \.self) { stat in
                                Text(stat.displayName).tag(stat)
                            }
                        }
                    }

                    TextField("Category", text: $category)
                        .textInputAutocapitalization(.words)

                    TextField("Location", text: $location)
                }

                Section("Event") {
                    Picker("Related Event", selection: $selectedEvent) {
                        Text("None").tag(nil as Event?)
                        ForEach(venueEvents) { event in
                            Text(event.eventName).tag(event as Event?)
                        }
                    }
                }

                Section("Assignment") {
                    TextField("Reported By", text: $reportedBy)
                    TextField("Assigned To", text: $assignedTo)
                }

                if isEditing {
                    Section("Actions & Notes") {
                        TextField("Actions Taken", text: $actionsTaken, axis: .vertical)
                            .lineLimit(4...8)

                        TextField("Additional Notes", text: $notes, axis: .vertical)
                            .lineLimit(4...8)
                    }
                }

                Section("Photo Evidence") {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        HStack {
                            Image(systemName: "photo")
                            Text("Select Photo")
                        }
                    }

                    if !photoUri.isEmpty {
                        Text("Photo attached")
                            .font(AppTheme.bodySmall)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Incident" : "Report Incident")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveIncident()
                    }
                    .disabled(title.isEmpty || incidentDescription.isEmpty)
                }
            }
            .onAppear {
                loadIncident()
            }
        }
    }

    private func loadIncident() {
        guard let incident = incident else { return }
        title = incident.title
        incidentDescription = incident.incidentDescription
        severity = incident.severity
        status = incident.status
        category = incident.category
        location = incident.location
        reportedBy = incident.reportedBy
        assignedTo = incident.assignedTo
        notes = incident.notes
        actionsTaken = incident.actionsTaken
        photoUri = incident.photoUri
        selectedEvent = incident.event
    }

    private func saveIncident() {
        if let incident = incident {
            // Update existing
            incident.title = title
            incident.incidentDescription = incidentDescription
            incident.severity = severity
            incident.status = status
            incident.category = category
            incident.location = location
            incident.reportedBy = reportedBy
            incident.assignedTo = assignedTo
            incident.notes = notes
            incident.actionsTaken = actionsTaken
            incident.photoUri = photoUri
            incident.event = selectedEvent
            incident.updatedAt = Date()

            if status == .resolved || status == .closed {
                if incident.resolvedAt == nil {
                    incident.resolvedAt = Date()
                }
            }
        } else {
            // Create new
            let newIncident = Incident(
                title: title,
                incidentDescription: incidentDescription,
                severity: severity,
                status: status,
                category: category,
                location: location,
                photoUri: photoUri,
                reportedBy: reportedBy,
                assignedTo: assignedTo,
                notes: notes,
                actionsTaken: actionsTaken,
                venue: venue,
                event: selectedEvent
            )
            modelContext.insert(newIncident)
        }

        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    let venue = Venue(name: "Test Venue", location: "Test City", code: "TEST")
    return AddEditIncidentScreen(venue: venue, incident: nil)
        .modelContainer(for: [Incident.self, Event.self])
}
