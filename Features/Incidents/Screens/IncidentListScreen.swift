//
//  IncidentListScreen.swift
//  EventMonitor
//
//  Screen showing incidents for a venue
//  Equivalent to Android IncidentListScreen.kt
//

import SwiftUI
import SwiftData

struct IncidentListScreen: View {
    @Environment(\.modelContext) private var modelContext

    let venue: Venue

    @Query private var incidents: [Incident]
    @State private var selectedSeverity: IncidentSeverity?
    @State private var selectedStatus: IncidentStatus?
    @State private var searchText = ""
    @State private var showingAddIncident = false
    @State private var selectedIncident: Incident?

    init(venue: Venue) {
        self.venue = venue
        let venueId = venue.id
        _incidents = Query(
            filter: #Predicate { $0.venue?.id == venueId },
            sort: \Incident.reportedAt,
            order: .reverse
        )
    }

    var filteredIncidents: [Incident] {
        var items = incidents

        if let severity = selectedSeverity {
            items = items.filter { $0.severity == severity }
        }

        if let status = selectedStatus {
            items = items.filter { $0.status == status }
        }

        if !searchText.isEmpty {
            items = items.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.incidentDescription.localizedCaseInsensitiveContains(searchText)
            }
        }

        return items
    }

    var body: some View {
        VStack(spacing: 0) {
            // Severity filter
            severityFilter

            // Status filter
            statusFilter

            // Incidents list
            if filteredIncidents.isEmpty {
                emptyState
            } else {
                incidentsList
            }
        }
        .navigationTitle("Incident Reports")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddIncident = true
                } label: {
                    Label("Report Incident", systemImage: "plus")
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search incidents...")
        .sheet(isPresented: $showingAddIncident) {
            AddEditIncidentScreen(venue: venue, incident: nil)
        }
        .sheet(item: $selectedIncident) { incident in
            AddEditIncidentScreen(venue: venue, incident: incident)
        }
    }

    private var severityFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.spacingS) {
                FilterChip(
                    title: "All Severity",
                    isSelected: selectedSeverity == nil,
                    count: incidents.count
                ) {
                    selectedSeverity = nil
                }

                ForEach(IncidentSeverity.allCases, id: \.self) { severity in
                    let count = incidents.filter { $0.severity == severity }.count
                    FilterChip(
                        title: severity.displayName,
                        isSelected: selectedSeverity == severity,
                        count: count,
                        color: severity.color
                    ) {
                        selectedSeverity = severity
                    }
                }
            }
            .padding(.horizontal, AppTheme.spacingM)
            .padding(.vertical, AppTheme.spacingS)
        }
        .background(Color(.systemGray6))
    }

    private var statusFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.spacingS) {
                FilterChip(
                    title: "All Status",
                    isSelected: selectedStatus == nil,
                    count: incidents.count
                ) {
                    selectedStatus = nil
                }

                ForEach(IncidentStatus.allCases, id: \.self) { status in
                    let count = incidents.filter { $0.status == status }.count
                    FilterChip(
                        title: status.displayName,
                        isSelected: selectedStatus == status,
                        count: count,
                        color: status.color
                    ) {
                        selectedStatus = status
                    }
                }
            }
            .padding(.horizontal, AppTheme.spacingM)
            .padding(.vertical, AppTheme.spacingS)
        }
        .background(Color(.systemGray6))
    }

    private var emptyState: some View {
        VStack(spacing: AppTheme.spacingL) {
            Image(systemName: "checkmark.shield")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "#66BB6A"))

            Text("No Incidents")
                .font(AppTheme.headlineMedium)

            Text("No incidents have been reported")
                .font(AppTheme.bodyMedium)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var incidentsList: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.spacingM) {
                ForEach(filteredIncidents) { incident in
                    IncidentCard(incident: incident)
                        .onTapGesture {
                            selectedIncident = incident
                        }
                }
            }
            .padding(AppTheme.spacingM)
        }
    }
}

struct IncidentCard: View {
    @Bindable var incident: Incident

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingM) {
            // Header with severity
            HStack {
                Image(systemName: incident.severity.icon)
                    .foregroundColor(incident.severity.color)
                    .font(.title3)

                Text(incident.title)
                    .font(AppTheme.titleLarge)
                    .lineLimit(2)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }

            // Description
            Text(incident.incidentDescription)
                .font(AppTheme.bodyMedium)
                .foregroundColor(.gray)
                .lineLimit(3)

            // Metadata
            HStack {
                Text(dateFormatter.string(from: incident.reportedAt))
                    .font(AppTheme.bodySmall)
                    .foregroundColor(.gray)

                if !incident.location.isEmpty {
                    Text("•")
                        .foregroundColor(.gray)
                    Text(incident.location)
                        .font(AppTheme.bodySmall)
                        .foregroundColor(.gray)
                }
            }

            // Badges
            HStack {
                // Severity badge
                Text(incident.severity.displayName)
                    .font(AppTheme.labelSmall)
                    .padding(.horizontal, AppTheme.spacingS)
                    .padding(.vertical, 4)
                    .background(incident.severity.color.opacity(0.2))
                    .foregroundColor(incident.severity.color)
                    .cornerRadius(AppTheme.radiusS)

                // Status badge
                Text(incident.status.displayName)
                    .font(AppTheme.labelSmall)
                    .padding(.horizontal, AppTheme.spacingS)
                    .padding(.vertical, 4)
                    .background(incident.status.color.opacity(0.2))
                    .foregroundColor(incident.status.color)
                    .cornerRadius(AppTheme.radiusS)

                Spacer()

                if !incident.assignedTo.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "person.circle")
                            .font(.caption)
                        Text(incident.assignedTo)
                            .font(AppTheme.labelSmall)
                    }
                    .foregroundColor(.gray)
                }
            }
        }
        .padding(AppTheme.spacingM)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.radiusL)
                .stroke(incident.severity.color.opacity(0.3), lineWidth: 2)
        )
        .background(AppTheme.surface)
        .cornerRadius(AppTheme.radiusL)
    }
}

#Preview {
    let venue = Venue(name: "Test Venue", location: "Test City", code: "TEST")
    return NavigationStack {
        IncidentListScreen(venue: venue)
            .modelContainer(for: [Venue.self, Incident.self])
    }
}
