//
//  ReportsScreen.swift
//  EventMonitor
//
//  Screen for viewing and exporting reports
//  Equivalent to Android ReportsScreen.kt
//

import SwiftUI
import SwiftData

struct ReportsScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var venues: [Venue]
    @Query private var events: [Event]

    @State private var selectedVenue: Venue?
    @State private var startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var endDate = Date()
    @State private var showingExportSheet = false

    var filteredEvents: [Event] {
        var filtered = events

        if let venue = selectedVenue {
            filtered = filtered.filter { $0.venue?.id == venue.id }
        }

        filtered = filtered.filter {
            $0.date >= startDate && $0.date <= endDate
        }

        return filtered.sorted { $0.date > $1.date }
    }

    var totalAttendance: Int {
        filteredEvents.reduce(0) { $0 + $1.totalAttendance }
    }

    var averageAttendance: Double {
        guard !filteredEvents.isEmpty else { return 0 }
        return Double(totalAttendance) / Double(filteredEvents.count)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.spacingL) {
                // Filters
                filtersSection

                // Summary cards
                summarySection

                // Events list
                eventsSection
            }
            .padding(AppTheme.spacingM)
        }
        .navigationTitle("Reports")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingExportSheet = true
                } label: {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                .disabled(filteredEvents.isEmpty)
            }
        }
        .sheet(isPresented: $showingExportSheet) {
            ExportSheet(events: filteredEvents)
        }
    }

    private var filtersSection: some View {
        VStack(spacing: AppTheme.spacingM) {
            Picker("Venue", selection: $selectedVenue) {
                Text("All Venues").tag(nil as Venue?)
                ForEach(venues) { venue in
                    Text(venue.name).tag(venue as Venue?)
                }
            }
            .pickerStyle(.menu)

            HStack {
                DatePicker("From", selection: $startDate, displayedComponents: .date)
                DatePicker("To", selection: $endDate, displayedComponents: .date)
            }
        }
        .padding(AppTheme.spacingM)
        .cardStyle()
    }

    private var summarySection: some View {
        VStack(spacing: AppTheme.spacingM) {
            HStack(spacing: AppTheme.spacingM) {
                StatCard(
                    title: "Total Events",
                    value: "\(filteredEvents.count)",
                    icon: "calendar",
                    color: Color(hex: "#42A5F5")
                )

                StatCard(
                    title: "Total Attendance",
                    value: "\(totalAttendance)",
                    icon: "person.3.fill",
                    color: Color(hex: "#66BB6A")
                )
            }

            HStack(spacing: AppTheme.spacingM) {
                StatCard(
                    title: "Average Attendance",
                    value: String(format: "%.0f", averageAttendance),
                    icon: "chart.bar.fill",
                    color: Color(hex: "#FFA726")
                )

                StatCard(
                    title: "Venues",
                    value: "\(selectedVenue == nil ? venues.count : 1)",
                    icon: "building.2.fill",
                    color: Color(hex: "#AB47BC")
                )
            }
        }
    }

    private var eventsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingM) {
            Text("Events")
                .font(AppTheme.titleLarge)

            if filteredEvents.isEmpty {
                VStack(spacing: AppTheme.spacingM) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    Text("No events in selected period")
                        .font(AppTheme.bodyMedium)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(AppTheme.spacingXL)
                .cardStyle()
            } else {
                ForEach(filteredEvents) { event in
                    EventReportRow(event: event)
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingS) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }

            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(AppTheme.onSurface)

            Text(title)
                .font(AppTheme.bodySmall)
                .foregroundColor(.gray)
        }
        .padding(AppTheme.spacingM)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

struct EventReportRow: View {
    let event: Event

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(event.eventName)
                    .font(AppTheme.titleMedium)

                Text(dateFormatter.string(from: event.date))
                    .font(AppTheme.bodySmall)
                    .foregroundColor(.gray)

                if let venue = event.venue {
                    Text(venue.name)
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
            }
        }
        .padding(AppTheme.spacingM)
        .cardStyle()
    }
}

struct ExportSheet: View {
    @Environment(\.dismiss) private var dismiss
    let events: [Event]

    var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.spacingL) {
                Image(systemName: "doc.text")
                    .font(.system(size: 60))
                    .foregroundColor(AppTheme.primary)

                Text("Export Report")
                    .font(AppTheme.headlineMedium)

                Text("Export \(events.count) events to CSV")
                    .font(AppTheme.bodyMedium)
                    .foregroundColor(.gray)

                Button("Export to CSV") {
                    exportToCSV()
                }
                .primaryButton()
                .padding(.top, AppTheme.spacingL)
            }
            .padding(AppTheme.spacingXL)
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func exportToCSV() {
        // TODO: Implement CSV export
        print("Exporting \(events.count) events to CSV")
        dismiss()
    }
}

#Preview {
    NavigationStack {
        ReportsScreen()
            .modelContainer(for: [Venue.self, Event.self])
    }
}
