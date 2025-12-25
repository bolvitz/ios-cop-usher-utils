//
//  AddEditLostItemScreen.swift
//  EventMonitor
//
//  Screen for adding/editing lost items
//  Equivalent to Android AddEditLostItemScreen.kt
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddEditLostItemScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var events: [Event]

    let venue: Venue
    let item: LostItem?

    @State private var description = ""
    @State private var category: ItemCategory = .other
    @State private var foundZone = ""
    @State private var foundDate = Date()
    @State private var color = ""
    @State private var brand = ""
    @State private var identifyingMarks = ""
    @State private var reportedBy = ""
    @State private var notes = ""
    @State private var selectedEvent: Event?
    @State private var status: ItemStatus = .pending

    // For claiming
    @State private var claimedBy = ""
    @State private var claimerContact = ""
    @State private var verificationNotes = ""

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoUri = ""

    private var isEditing: Bool {
        item != nil
    }

    private var venueEvents: [Event] {
        events.filter { $0.venue?.id == venue.id }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Item Details") {
                    TextField("Description", text: $description)

                    Picker("Category", selection: $category) {
                        ForEach(ItemCategory.allCases, id: \.self) { cat in
                            HStack {
                                Text(cat.icon)
                                Text(cat.displayName)
                            }
                            .tag(cat)
                        }
                    }

                    TextField("Found Zone/Area", text: $foundZone)

                    DatePicker("Found Date", selection: $foundDate, displayedComponents: [.date, .hourAndMinute])
                }

                Section("Additional Details") {
                    TextField("Color", text: $color)
                    TextField("Brand", text: $brand)
                    TextField("Identifying Marks", text: $identifyingMarks, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Event") {
                    Picker("Related Event", selection: $selectedEvent) {
                        Text("None").tag(nil as Event?)
                        ForEach(venueEvents) { event in
                            Text(event.eventName).tag(event as Event?)
                        }
                    }
                }

                Section("Reporting") {
                    TextField("Reported By", text: $reportedBy)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                if isEditing {
                    Section("Status") {
                        Picker("Status", selection: $status) {
                            ForEach(ItemStatus.allCases, id: \.self) { status in
                                Text(status.displayName).tag(status)
                            }
                        }

                        if status == .claimed {
                            TextField("Claimed By", text: $claimedBy)
                            TextField("Claimer Contact", text: $claimerContact)
                            TextField("Verification Notes", text: $verificationNotes, axis: .vertical)
                                .lineLimit(3...6)
                        }

                        if let item = item, item.status == .pending {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Donation Countdown")
                                    .font(AppTheme.labelMedium)
                                    .foregroundColor(.gray)

                                Text("\(item.daysUntilDonation) days remaining")
                                    .font(AppTheme.bodyMedium)

                                if item.canBeDonated {
                                    Text("This item can now be donated")
                                        .font(AppTheme.bodySmall)
                                        .foregroundColor(Color(hex: "#66BB6A"))
                                }
                            }
                        }
                    }
                }

                Section("Photo") {
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
            .navigationTitle(isEditing ? "Edit Lost Item" : "New Lost Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(description.isEmpty)
                }
            }
            .onAppear {
                loadItem()
            }
        }
    }

    private func loadItem() {
        guard let item = item else { return }
        description = item.itemDescription
        category = item.category
        foundZone = item.foundZone
        foundDate = item.foundDate
        color = item.color
        brand = item.brand
        identifyingMarks = item.identifyingMarks
        reportedBy = item.reportedBy
        notes = item.notes
        status = item.status
        photoUri = item.photoUri
        selectedEvent = item.event
        claimedBy = item.claimedBy
        claimerContact = item.claimerContact
        verificationNotes = item.verificationNotes
    }

    private func saveItem() {
        if let item = item {
            // Update existing
            item.itemDescription = description
            item.category = category
            item.foundZone = foundZone
            item.foundDate = foundDate
            item.color = color
            item.brand = brand
            item.identifyingMarks = identifyingMarks
            item.reportedBy = reportedBy
            item.notes = notes
            item.status = status
            item.photoUri = photoUri
            item.event = selectedEvent
            item.updatedAt = Date()

            if status == .claimed {
                item.claimedBy = claimedBy
                item.claimerContact = claimerContact
                item.verificationNotes = verificationNotes
                item.claimedDate = Date()
            }
        } else {
            // Create new
            let newItem = LostItem(
                itemDescription: description,
                category: category,
                foundZone: foundZone,
                foundDate: foundDate,
                photoUri: photoUri,
                color: color,
                brand: brand,
                identifyingMarks: identifyingMarks,
                reportedBy: reportedBy,
                notes: notes,
                venue: venue,
                event: selectedEvent
            )
            modelContext.insert(newItem)
        }

        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    let venue = Venue(name: "Test Venue", location: "Test City", code: "TEST")
    return AddEditLostItemScreen(venue: venue, item: nil)
        .modelContainer(for: [LostItem.self, Event.self])
}
