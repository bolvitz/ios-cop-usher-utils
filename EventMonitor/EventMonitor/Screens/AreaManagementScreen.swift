//
//  AreaManagementScreen.swift
//  EventMonitor
//
//  Screen for managing venue areas/zones
//  Equivalent to Android AreaManagementScreen.kt
//

import SwiftUI
import SwiftData

struct AreaManagementScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let venue: Venue
    @State private var showingAddArea = false
    @State private var editingArea: AreaTemplate?

    var body: some View {
        List {
            if venue.areas.isEmpty {
                emptyState
            } else {
                ForEach(venue.areas.sorted(by: { $0.displayOrder < $1.displayOrder })) { area in
                    AreaRow(area: area)
                        .onTapGesture {
                            editingArea = area
                        }
                }
                .onMove(perform: moveArea)
                .onDelete(perform: deleteArea)
            }
        }
        .navigationTitle("Manage Areas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddArea = true
                } label: {
                    Image(systemName: "plus")
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }
        }
        .sheet(isPresented: $showingAddArea) {
            AreaEditView(venue: venue, area: nil)
        }
        .sheet(item: $editingArea) { area in
            AreaEditView(venue: venue, area: area)
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppTheme.spacingM) {
            Image(systemName: "square.split.2x2")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.primary.opacity(0.5))

            Text("No Areas Yet")
                .font(AppTheme.titleLarge)

            Text("Add areas to organize your venue for head counting")
                .font(AppTheme.bodyMedium)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .listRowBackground(Color.clear)
    }

    private func moveArea(from source: IndexSet, to destination: Int) {
        var sortedAreas = venue.areas.sorted(by: { $0.displayOrder < $1.displayOrder })
        sortedAreas.move(fromOffsets: source, toOffset: destination)

        for (index, area) in sortedAreas.enumerated() {
            area.displayOrder = index
        }

        try? modelContext.save()
    }

    private func deleteArea(at offsets: IndexSet) {
        let sortedAreas = venue.areas.sorted(by: { $0.displayOrder < $1.displayOrder })
        for index in offsets {
            modelContext.delete(sortedAreas[index])
        }

        try? modelContext.save()
    }
}

struct AreaRow: View {
    let area: AreaTemplate

    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            Image(systemName: area.icon)
                .foregroundColor(Color(hex: area.color))
                .font(.title2)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(area.name)
                    .font(AppTheme.titleMedium)

                HStack {
                    Text(area.type.displayName)
                        .font(AppTheme.bodySmall)
                        .foregroundColor(.gray)

                    Text("•")
                        .foregroundColor(.gray)

                    Text("Capacity: \(area.capacity)")
                        .font(AppTheme.bodySmall)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding(.vertical, AppTheme.spacingS)
    }
}

struct AreaEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let venue: Venue
    let area: AreaTemplate?

    @State private var name = ""
    @State private var type: ZoneType = .generalAdmission
    @State private var capacity = ""
    @State private var color = "#2196F3"
    @State private var icon = "person.2.fill"

    private var isEditing: Bool {
        area != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Area Details") {
                    TextField("Area Name", text: $name)

                    Picker("Type", selection: $type) {
                        ForEach(ZoneType.allCases, id: \.self) { zoneType in
                            Text(zoneType.displayName).tag(zoneType)
                        }
                    }

                    TextField("Capacity", text: $capacity)
                        .keyboardType(.numberPad)
                }

                Section("Appearance") {
                    ColorPicker("Area Color", selection: Binding(
                        get: { Color(hex: color) },
                        set: { color = $0.toHex() }
                    ))

                    HStack {
                        Text("Icon")
                        Spacer()
                        Image(systemName: icon)
                            .foregroundColor(Color(hex: color))
                        Text(icon)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Area" : "New Area")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveArea()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                loadArea()
            }
        }
    }

    private func loadArea() {
        guard let area = area else { return }
        name = area.name
        type = area.type
        capacity = "\(area.capacity)"
        color = area.color
        icon = area.icon
    }

    private func saveArea() {
        let capacityValue = Int(capacity) ?? 0

        if let area = area {
            // Update existing
            area.name = name
            area.type = type
            area.capacity = capacityValue
            area.color = color
            area.icon = icon
            area.updatedAt = Date()
        } else {
            // Create new
            let newArea = AreaTemplate(
                name: name,
                type: type,
                capacity: capacityValue,
                displayOrder: venue.areas.count,
                color: color,
                icon: icon,
                venue: venue
            )
            modelContext.insert(newArea)
        }

        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    let venue = Venue(name: "Test Venue", location: "Test Location", code: "TEST")
    return NavigationStack {
        AreaManagementScreen(venue: venue)
            .modelContainer(for: [Venue.self, AreaTemplate.self])
    }
}
