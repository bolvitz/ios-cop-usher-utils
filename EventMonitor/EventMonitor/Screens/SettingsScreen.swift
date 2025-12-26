//
//  SettingsScreen.swift
//  EventMonitor
//
//  Settings screen for managing event types and preferences
//  Equivalent to Android SettingsScreen.kt
//

import SwiftUI
import SwiftData

struct SettingsScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var eventTypes: [EventType]

    @State private var showingAddEventType = false
    @State private var editingEventType: EventType?

    var body: some View {
        List {
            Section {
                NavigationLink {
                    VenueSetupScreen(venue: nil)
                } label: {
                    Label("Add Venue", systemImage: "plus.circle.fill")
                        .foregroundColor(AppTheme.primary)
                }
            }

            Section("Event Types") {
                if eventTypes.isEmpty {
                    Text("No event types configured")
                        .foregroundColor(.gray)
                        .font(AppTheme.bodyMedium)
                } else {
                    ForEach(eventTypes.sorted(by: { $0.displayOrder < $1.displayOrder })) { eventType in
                        EventTypeRow(eventType: eventType)
                            .onTapGesture {
                                editingEventType = eventType
                            }
                    }
                    .onMove(perform: moveEventType)
                    .onDelete(perform: deleteEventType)
                }

                Button {
                    showingAddEventType = true
                } label: {
                    Label("Add Event Type", systemImage: "plus.circle")
                }
            }

            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.gray)
                }

                HStack {
                    Text("Platform")
                    Spacer()
                    Text("iOS")
                        .foregroundColor(.gray)
                }
            }

            Section {
                Link(destination: URL(string: "https://github.com/bolvitz/ios-cop-usher-utils")!) {
                    HStack {
                        Label("Source Code", systemImage: "chevron.left.forwardslash.chevron.right")
                        Spacer()
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }
        }
        .sheet(isPresented: $showingAddEventType) {
            EventTypeEditView(eventType: nil)
        }
        .sheet(item: $editingEventType) { eventType in
            EventTypeEditView(eventType: eventType)
        }
    }

    private func moveEventType(from source: IndexSet, to destination: Int) {
        var sortedTypes = eventTypes.sorted(by: { $0.displayOrder < $1.displayOrder })
        sortedTypes.move(fromOffsets: source, toOffset: destination)

        for (index, type) in sortedTypes.enumerated() {
            type.displayOrder = index
        }

        try? modelContext.save()
    }

    private func deleteEventType(at offsets: IndexSet) {
        let sortedTypes = eventTypes.sorted(by: { $0.displayOrder < $1.displayOrder })
        for index in offsets {
            modelContext.delete(sortedTypes[index])
        }

        try? modelContext.save()
    }
}

struct EventTypeRow: View {
    @Bindable var eventType: EventType

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(eventType.name)
                .font(AppTheme.titleMedium)

            HStack {
                if !eventType.dayType.isEmpty {
                    Text(eventType.dayType)
                        .font(AppTheme.bodySmall)
                        .foregroundColor(.gray)
                }

                if !eventType.time.isEmpty {
                    if !eventType.dayType.isEmpty {
                        Text("•")
                            .foregroundColor(.gray)
                    }
                    Text(eventType.time)
                        .font(AppTheme.bodySmall)
                        .foregroundColor(.gray)
                }
            }

            if !eventType.isActive {
                Text("Inactive")
                    .font(AppTheme.labelSmall)
                    .padding(.horizontal, AppTheme.spacingS)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.gray)
                    .cornerRadius(AppTheme.radiusS)
            }
        }
        .padding(.vertical, AppTheme.spacingS)
    }
}

struct EventTypeEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let eventType: EventType?

    @State private var name = ""
    @State private var dayType = ""
    @State private var time = ""
    @State private var eventDescription = ""
    @State private var isActive = true
    @State private var errorMessage = ""
    @State private var showingError = false

    private var isEditing: Bool {
        eventType != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Event Type Details") {
                    TextField("Name (e.g., Sunday Service)", text: $name)

                    TextField("Day (e.g., Sunday)", text: $dayType)

                    TextField("Time (e.g., 9:00 AM)", text: $time)

                    TextField("Description", text: $eventDescription, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section {
                    Toggle("Active", isOn: $isActive)
                }

                if showingError {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(AppTheme.bodySmall)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Event Type" : "New Event Type")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEventType()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                loadEventType()
            }
        }
    }

    private func loadEventType() {
        guard let eventType = eventType else { return }
        name = eventType.name
        dayType = eventType.dayType
        time = eventType.time
        eventDescription = eventType.eventDescription
        isActive = eventType.isActive
    }

    private func saveEventType() {
        // Validate input
        let validationResult = DomainValidators.validateEventTypeInput(
            name: name,
            dayType: dayType,
            time: time,
            description: eventDescription.isEmpty ? nil : eventDescription
        )

        if case .failure(let error) = validationResult {
            errorMessage = error.message
            showingError = true
            return
        }

        // Check for duplicate name
        let eventTypeId = eventType?.id ?? ""
        let descriptor = FetchDescriptor<EventType>(
            predicate: #Predicate { $0.name == name && $0.id != eventTypeId }
        )
        if let existingTypes = try? modelContext.fetch(descriptor), !existingTypes.isEmpty {
            errorMessage = "An event type with name '\(name)' already exists"
            showingError = true
            return
        }

        if let eventType = eventType {
            // Update existing
            eventType.name = name
            eventType.dayType = dayType
            eventType.time = time
            eventType.eventDescription = eventDescription
            eventType.isActive = isActive
            eventType.updatedAt = Date()
        } else {
            // Create new
            // Get the next display order
            let descriptor = FetchDescriptor<EventType>(sortBy: [SortDescriptor(\.displayOrder, order: .reverse)])
            let maxOrder = (try? modelContext.fetch(descriptor).first?.displayOrder) ?? -1

            let newEventType = EventType(
                name: name,
                dayType: dayType,
                time: time,
                eventDescription: eventDescription,
                displayOrder: maxOrder + 1,
                isActive: isActive
            )
            modelContext.insert(newEventType)
        }

        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = "Failed to save event type: \(error.localizedDescription)"
            showingError = true
        }
    }
}

#Preview {
    NavigationStack {
        SettingsScreen()
            .modelContainer(for: EventType.self)
    }
}
