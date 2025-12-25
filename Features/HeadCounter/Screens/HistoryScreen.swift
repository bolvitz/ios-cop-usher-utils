//
//  HistoryScreen.swift
//  EventMonitor
//
//  Screen showing event history for a venue
//  Equivalent to Android HistoryScreen.kt
//

import SwiftUI
import SwiftData

struct HistoryScreen: View {
    @Environment(\.modelContext) private var modelContext

    let venue: Venue

    @Query private var events: [Event]
    @State private var showingNewEvent = false
    @State private var selectedEvent: Event?

    init(venue: Venue) {
        self.venue = venue
        let venueId = venue.id
        _events = Query(
            filter: #Predicate { $0.venue?.id == venueId },
            sort: \Event.date,
            order: .reverse
        )
    }

    var body: some View {
        ZStack {
            if events.isEmpty {
                emptyState
            } else {
                eventList
            }

            // Floating Action Button (matching Android pattern)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showingNewEvent = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(AppTheme.primary)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .padding(.trailing, AppTheme.spacingM)
                    .padding(.bottom, AppTheme.spacingM)
                }
            }
        }
        .navigationTitle("Head Count History")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingNewEvent) {
            NewEventView(venue: venue)
        }
        .navigationDestination(item: $selectedEvent) { event in
            CountingScreen(event: event)
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppTheme.spacingL) {
            Image(systemName: "calendar")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.primary.opacity(0.5))

            Text("No Events Yet")
                .font(AppTheme.headlineMedium)

            Text("Create your first event to start counting")
                .font(AppTheme.bodyMedium)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            Button("New Event") {
                showingNewEvent = true
            }
            .primaryButton()
        }
        .padding(AppTheme.spacingXL)
    }

    private var eventList: some View {
        List {
            ForEach(events) { event in
                EventRow(event: event)
                    .onTapGesture {
                        selectedEvent = event
                    }
            }
            .onDelete(perform: deleteEvents)
        }
    }

    private func deleteEvents(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(events[index])
        }
        try? modelContext.save()
    }
}

struct EventRow: View {
    let event: Event

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(event.eventName.isEmpty ? "Event" : event.eventName)
                    .font(AppTheme.titleMedium)

                Text(dateFormatter.string(from: event.date))
                    .font(AppTheme.bodySmall)
                    .foregroundColor(.gray)

                if !event.countedBy.isEmpty {
                    Text("Counted by: \(event.countedBy)")
                        .font(AppTheme.bodySmall)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(event.totalAttendance)")
                    .font(AppTheme.headlineSmall)
                    .foregroundColor(AppTheme.primary)

                if event.totalCapacity > 0 {
                    let percentage = Double(event.totalAttendance) / Double(event.totalCapacity) * 100
                    Text("\(Int(percentage))%")
                        .font(AppTheme.bodySmall)
                        .foregroundColor(.gray)
                }

                if event.isLocked {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, AppTheme.spacingS)
    }
}

struct NewEventView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var eventTypes: [EventType]

    let venue: Venue

    @State private var selectedEventType: EventType?
    @State private var counterName = ""
    @State private var notes = ""
    @State private var navigateToCount = false
    @State private var createdEvent: Event?

    var body: some View {
        NavigationStack {
            Form {
                Section("Event Details") {
                    Picker("Event Type", selection: $selectedEventType) {
                        Text("None").tag(nil as EventType?)
                        ForEach(eventTypes.filter { $0.isActive }) { type in
                            Text(type.name).tag(type as EventType?)
                        }
                    }

                    TextField("Counter Name", text: $counterName)
                    TextField("Notes", text: $notes)
                }
            }
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Start Counting") {
                        createEvent()
                    }
                    .disabled(counterName.isEmpty)
                }
            }
            .navigationDestination(isPresented: $navigateToCount) {
                if let event = createdEvent {
                    CountingScreen(event: event)
                }
            }
        }
    }

    private func createEvent() {
        let newEvent = Event(
            eventName: selectedEventType?.name ?? "Event",
            countedBy: counterName,
            notes: notes,
            venue: venue,
            eventType: selectedEventType
        )

        // Create area counts for each venue area
        for area in venue.areas {
            let areaCount = AreaCount(
                capacity: area.capacity,
                event: newEvent,
                areaTemplate: area
            )
            modelContext.insert(areaCount)
        }

        modelContext.insert(newEvent)
        try? modelContext.save()

        createdEvent = newEvent
        navigateToCount = true
        dismiss()
    }
}

#Preview {
    let venue = Venue(name: "Test Church", location: "Test City", code: "TC")
    return NavigationStack {
        HistoryScreen(venue: venue)
            .modelContainer(for: [Venue.self, Event.self, EventType.self])
    }
}
