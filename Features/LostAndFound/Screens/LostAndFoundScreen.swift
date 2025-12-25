//
//  LostAndFoundScreen.swift
//  EventMonitor
//
//  Screen showing lost items for a venue
//  Equivalent to Android LostAndFoundScreen.kt
//

import SwiftUI
import SwiftData

struct LostAndFoundScreen: View {
    @Environment(\.modelContext) private var modelContext

    let venue: Venue

    @Query private var lostItems: [LostItem]
    @State private var selectedStatus: ItemStatus?  = nil
    @State private var searchText = ""
    @State private var showingAddItem = false
    @State private var selectedItem: LostItem?

    init(venue: Venue) {
        self.venue = venue
        let venueId = venue.id
        _lostItems = Query(
            filter: #Predicate { $0.venue?.id == venueId },
            sort: \LostItem.foundDate,
            order: .reverse
        )
    }

    var filteredItems: [LostItem] {
        var items = lostItems

        if let status = selectedStatus {
            items = items.filter { $0.status == status }
        }

        if !searchText.isEmpty {
            items = items.filter {
                $0.itemDescription.localizedCaseInsensitiveContains(searchText) ||
                $0.category.displayName.localizedCaseInsensitiveContains(searchText)
            }
        }

        return items
    }

    var body: some View {
        VStack(spacing: 0) {
            // Filter toolbar
            filterSection

            // Items list
            if filteredItems.isEmpty {
                emptyState
            } else {
                itemsList
            }
        }
        .navigationTitle("Lost & Found")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddItem = true
                } label: {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search items...")
        .sheet(isPresented: $showingAddItem) {
            AddEditLostItemScreen(venue: venue, item: nil)
        }
        .sheet(item: $selectedItem) { item in
            AddEditLostItemScreen(venue: venue, item: item)
        }
    }

    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.spacingS) {
                FilterChip(
                    title: "All",
                    isSelected: selectedStatus == nil,
                    count: lostItems.count
                ) {
                    selectedStatus = nil
                }

                ForEach(ItemStatus.allCases, id: \.self) { status in
                    let count = lostItems.filter { $0.status == status }.count
                    FilterChip(
                        title: status.displayName,
                        isSelected: selectedStatus == status,
                        count: count,
                        color: Color(hex: status.color)
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
            Image(systemName: "shippingbox")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.primary.opacity(0.5))

            Text(selectedStatus == nil ? "No Lost Items" : "No \(selectedStatus!.displayName) Items")
                .font(AppTheme.headlineMedium)

            Text("Add lost items to track them")
                .font(AppTheme.bodyMedium)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var itemsList: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.spacingM) {
                ForEach(filteredItems) { item in
                    LostItemCard(item: item)
                        .onTapGesture {
                            selectedItem = item
                        }
                }
            }
            .padding(AppTheme.spacingM)
        }
    }
}

struct LostItemCard: View {
    @ObservedObject var item: LostItem

    var body: some View {
        HStack(spacing: AppTheme.spacingM) {
            // Category icon
            Text(item.category.icon)
                .font(.system(size: 40))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.itemDescription)
                    .font(AppTheme.titleMedium)
                    .lineLimit(2)

                HStack {
                    Text(item.category.displayName)
                        .font(AppTheme.bodySmall)
                        .foregroundColor(.gray)

                    if !item.foundZone.isEmpty {
                        Text("•")
                            .foregroundColor(.gray)
                        Text(item.foundZone)
                            .font(AppTheme.bodySmall)
                            .foregroundColor(.gray)
                    }
                }

                // Status badge
                HStack {
                    Text(item.status.displayName)
                        .font(AppTheme.labelSmall)
                        .padding(.horizontal, AppTheme.spacingS)
                        .padding(.vertical, 4)
                        .background(Color(hex: item.status.color).opacity(0.2))
                        .foregroundColor(Color(hex: item.status.color))
                        .cornerRadius(AppTheme.radiusS)

                    if item.status == .pending && item.daysUntilDonation > 0 {
                        Text("\(item.daysUntilDonation) days until donation")
                            .font(AppTheme.labelSmall)
                            .foregroundColor(.gray)
                    } else if item.canBeDonated {
                        Text("Can be donated")
                            .font(AppTheme.labelSmall)
                            .foregroundColor(Color(hex: "#66BB6A"))
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding(AppTheme.spacingM)
        .cardStyle()
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var count: Int = 0
    var color: Color = AppTheme.primary

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                    .font(AppTheme.labelMedium)

                if count > 0 {
                    Text("(\(count))")
                        .font(AppTheme.labelSmall)
                }
            }
            .padding(.horizontal, AppTheme.spacingM)
            .padding(.vertical, AppTheme.spacingS)
            .background(isSelected ? color : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(AppTheme.radiusL)
        }
    }
}

#Preview {
    let venue = Venue(name: "Test Venue", location: "Test City", code: "TEST")
    return NavigationStack {
        LostAndFoundScreen(venue: venue)
            .modelContainer(for: [Venue.self, LostItem.self])
    }
}
