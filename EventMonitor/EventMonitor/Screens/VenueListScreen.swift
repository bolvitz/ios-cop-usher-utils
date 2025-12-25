//
//  VenueListScreen.swift
//  EventMonitor
//
//  Main screen showing list of venues
//  Equivalent to Android VenueListScreen.kt
//

import SwiftUI
import SwiftData

struct VenueListScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Venue.name) private var venues: [Venue]
    @State private var showingAddVenue = false
    @State private var showingSettings = false
    @State private var showingReports = false
    @State private var selectedVenue: Venue?

    var body: some View {
        ZStack {
            if venues.isEmpty {
                emptyState
            } else {
                venueList
            }
        }
        .navigationTitle("Event Monitor")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showingReports = true
                    } label: {
                        Label("Reports", systemImage: "chart.bar.fill")
                    }

                    Button {
                        showingSettings = true
                    } label: {
                        Label("Settings", systemImage: "gearshape.fill")
                    }

                    Button {
                        showingAddVenue = true
                    } label: {
                        Label("Add Venue", systemImage: "plus.circle.fill")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .foregroundColor(AppTheme.primary)
                        .font(.title2)
                }
            }
        }
        .sheet(isPresented: $showingAddVenue) {
            NavigationStack {
                VenueSetupScreen(venue: nil)
            }
        }
        .sheet(isPresented: $showingSettings) {
            NavigationStack {
                SettingsScreen()
            }
        }
        .sheet(isPresented: $showingReports) {
            NavigationStack {
                ReportsScreen()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppTheme.spacingL) {
            Image(systemName: "building.2.fill")
                .font(.system(size: 80))
                .foregroundColor(AppTheme.primary.opacity(0.5))

            Text("No Venues Yet")
                .font(AppTheme.headlineMedium)
                .foregroundColor(AppTheme.onBackground)

            Text("Add your first venue to start tracking events")
                .font(AppTheme.bodyMedium)
                .foregroundColor(AppTheme.onBackground.opacity(0.6))
                .multilineTextAlignment(.center)

            Button("Add Venue") {
                showingAddVenue = true
            }
            .primaryButton()
        }
        .padding(AppTheme.spacingXL)
    }

    private var venueList: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.spacingM) {
                ForEach(venues) { venue in
                    VenueCard(venue: venue)
                }
            }
            .padding(AppTheme.spacingM)
        }
    }
}

struct VenueCard: View {
    let venue: Venue
    @State private var showingVenueSetup = false
    @State private var selectedFeature: VenueFeature?

    enum VenueFeature {
        case headCount, lostAndFound, incidents
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingM) {
            // Header
            HStack {
                Circle()
                    .fill(Color(hex: venue.color))
                    .frame(width: 12, height: 12)

                VStack(alignment: .leading, spacing: 4) {
                    Text(venue.name)
                        .font(AppTheme.titleLarge)
                        .foregroundColor(AppTheme.onSurface)

                    Text(venue.location)
                        .font(AppTheme.bodyMedium)
                        .foregroundColor(AppTheme.onSurface.opacity(0.6))
                }

                Spacer()

                Button {
                    showingVenueSetup = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(AppTheme.primary)
                }
            }

            // Area count
            if !venue.areas.isEmpty {
                Text("\(venue.areas.count) areas configured")
                    .font(AppTheme.bodySmall)
                    .foregroundColor(AppTheme.onSurface.opacity(0.6))
            }

            Divider()

            // Feature buttons
            VStack(spacing: AppTheme.spacingS) {
                if venue.isHeadCountEnabled {
                    FeatureButton(
                        title: "Head Count",
                        icon: "person.3.fill",
                        color: Color(hex: "#42A5F5")
                    ) {
                        selectedFeature = .headCount
                    }
                }

                if venue.isLostAndFoundEnabled {
                    FeatureButton(
                        title: "Lost & Found",
                        icon: "shippingbox.fill",
                        color: Color(hex: "#FFA726")
                    ) {
                        selectedFeature = .lostAndFound
                    }
                }

                if venue.isIncidentReportingEnabled {
                    FeatureButton(
                        title: "Incident Reporting",
                        icon: "exclamationmark.triangle.fill",
                        color: Color(hex: "#EF5350")
                    ) {
                        selectedFeature = .incidents
                    }
                }
            }
        }
        .padding(AppTheme.spacingM)
        .cardStyle()
        .sheet(isPresented: $showingVenueSetup) {
            NavigationStack {
                VenueSetupScreen(venue: venue)
            }
        }
        .navigationDestination(item: $selectedFeature) { feature in
            switch feature {
            case .headCount:
                HistoryScreen(venue: venue)
            case .lostAndFound:
                LostAndFoundScreen(venue: venue)
            case .incidents:
                IncidentListScreen(venue: venue)
            }
        }
    }
}

struct FeatureButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)

                Text(title)
                    .font(AppTheme.labelLarge)
                    .foregroundColor(AppTheme.onSurface)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(AppTheme.onSurface.opacity(0.3))
                    .font(.caption)
            }
            .padding(AppTheme.spacingM)
            .background(color.opacity(0.1))
            .cornerRadius(AppTheme.radiusM)
        }
    }
}

#Preview {
    NavigationStack {
        VenueListScreen()
            .modelContainer(for: [Venue.self, AreaTemplate.self, Event.self])
    }
}
