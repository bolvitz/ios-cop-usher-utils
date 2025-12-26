//
//  CountingScreen.swift
//  EventMonitor
//
//  Main counting screen with +/- buttons for each area
//  Equivalent to Android CountingScreen.kt
//

import SwiftUI
import SwiftData

struct CountingScreen: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: CountingViewModel

    init(event: Event) {
        _viewModel = StateObject(wrappedValue: CountingViewModel(event: event))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with total count
            totalSection

            Divider()

            // Area counts
            ScrollView {
                LazyVStack(spacing: AppTheme.spacingM) {
                    ForEach(viewModel.areaCounts.sorted(by: {
                        ($0.areaTemplate?.displayOrder ?? 0) < ($1.areaTemplate?.displayOrder ?? 0)
                    })) { areaCount in
                        AreaCountCard(
                            areaCount: areaCount,
                            onIncrement: { viewModel.increment(areaCount) },
                            onDecrement: { viewModel.decrement(areaCount) }
                        )
                    }
                }
                .padding(AppTheme.spacingM)
            }

            // Bottom toolbar
            bottomToolbar
        }
        .navigationTitle(viewModel.event.eventName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        viewModel.shareReport()
                    } label: {
                        Label("Share Report", systemImage: "square.and.arrow.up")
                    }

                    Button(role: .destructive) {
                        viewModel.lockEvent()
                    } label: {
                        Label("Lock Event", systemImage: "lock.fill")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
    }

    private var totalSection: some View {
        VStack(spacing: AppTheme.spacingS) {
            Text("Total Attendance")
                .font(AppTheme.titleMedium)
                .foregroundColor(.gray)

            Text("\(viewModel.totalAttendance)")
                .font(.system(size: 72, weight: .bold))
                .foregroundColor(AppTheme.primary)

            if viewModel.totalCapacity > 0 {
                let percentage = Double(viewModel.totalAttendance) / Double(viewModel.totalCapacity) * 100
                Text("\(Int(percentage))% of capacity")
                    .font(AppTheme.bodyMedium)
                    .foregroundColor(.gray)

                ProgressView(value: Double(viewModel.totalAttendance), total: Double(viewModel.totalCapacity))
                    .tint(capacityColor(percentage: percentage))
                    .padding(.horizontal, AppTheme.spacingXL)
            }
        }
        .padding(AppTheme.spacingL)
        .background(Color(.systemBackground))
    }

    private var bottomToolbar: some View {
        HStack(spacing: AppTheme.spacingL) {
            Button {
                viewModel.undo()
            } label: {
                Image(systemName: "arrow.uturn.backward.circle.fill")
                    .font(.title)
                    .foregroundColor(viewModel.canUndo ? AppTheme.primary : .gray)
            }
            .disabled(!viewModel.canUndo)

            Spacer()

            Button {
                viewModel.redo()
            } label: {
                Image(systemName: "arrow.uturn.forward.circle.fill")
                    .font(.title)
                    .foregroundColor(viewModel.canRedo ? AppTheme.primary : .gray)
            }
            .disabled(!viewModel.canRedo)
        }
        .padding(AppTheme.spacingL)
        .background(Color(.systemGray6))
    }

    private func capacityColor(percentage: Double) -> Color {
        switch percentage {
        case 0..<60:
            return Color(hex: "#66BB6A")  // Green
        case 60..<80:
            return Color(hex: "#FFA726")  // Orange
        case 80..<100:
            return Color(hex: "#FF7043")  // Deep Orange
        default:
            return Color(hex: "#EF5350")  // Red
        }
    }
}

struct AreaCountCard: View {
    @Bindable var areaCount: AreaCount
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View {
        VStack(spacing: AppTheme.spacingM) {
            // Header
            HStack {
                if let area = areaCount.areaTemplate {
                    Image(systemName: area.icon)
                        .foregroundColor(Color(hex: area.color))
                        .font(.title2)

                    Text(area.name)
                        .font(AppTheme.titleLarge)
                        .foregroundColor(AppTheme.onSurface)
                }

                Spacer()
            }

            // Count display
            HStack(spacing: AppTheme.spacingXL) {
                // Decrement button
                Button(action: onDecrement) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color(hex: "#EF5350"))
                }
                .disabled(areaCount.count <= 0)

                // Count
                Text("\(areaCount.count)")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(AppTheme.primary)
                    .frame(minWidth: 100)
                    .contentTransition(.numericText())

                // Increment button
                Button(action: onIncrement) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color(hex: "#66BB6A"))
                }
            }
            .padding(.vertical, AppTheme.spacingM)

            // Capacity info
            if areaCount.capacity > 0 {
                VStack(spacing: AppTheme.spacingS) {
                    let percentage = Double(areaCount.count) / Double(areaCount.capacity) * 100

                    HStack {
                        Text("\(areaCount.count) / \(areaCount.capacity)")
                            .font(AppTheme.bodyMedium)
                            .foregroundColor(.gray)

                        Spacer()

                        Text("\(Int(percentage))%")
                            .font(AppTheme.bodyMedium)
                            .foregroundColor(.gray)
                    }

                    ProgressView(value: Double(areaCount.count), total: Double(areaCount.capacity))
                        .tint(capacityColor(percentage: percentage))
                }
            }
        }
        .padding(AppTheme.spacingM)
        .cardStyle()
    }

    private func capacityColor(percentage: Double) -> Color {
        switch percentage {
        case 0..<60:
            return Color(hex: "#66BB6A")  // Green
        case 60..<80:
            return Color(hex: "#FFA726")  // Orange
        case 80..<100:
            return Color(hex: "#FF7043")  // Deep Orange
        default:
            return Color(hex: "#EF5350")  // Red
        }
    }
}

@MainActor
class CountingViewModel: ObservableObject {
    @Published var event: Event
    @Published var areaCounts: [AreaCount] = []
    @Published var totalAttendance: Int = 0
    @Published var totalCapacity: Int = 0
    @Published var canUndo: Bool = false
    @Published var canRedo: Bool = false

    private var modelContext: ModelContext?
    private var undoStack: [(AreaCount, Int)] = []
    private var redoStack: [(AreaCount, Int)] = []

    init(event: Event) {
        self.event = event
        loadAreaCounts()
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    func loadAreaCounts() {
        areaCounts = event.areaCounts
        updateTotals()
    }

    func increment(_ areaCount: AreaCount) {
        let oldValue = areaCount.count
        undoStack.append((areaCount, oldValue))
        redoStack.removeAll()

        areaCount.count += 1
        areaCount.addToHistory(areaCount.count)
        areaCount.updatedAt = Date()

        updateTotals()
        save()
        updateUndoRedoState()

        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    func decrement(_ areaCount: AreaCount) {
        guard areaCount.count > 0 else { return }

        let oldValue = areaCount.count
        undoStack.append((areaCount, oldValue))
        redoStack.removeAll()

        areaCount.count -= 1
        areaCount.addToHistory(areaCount.count)
        areaCount.updatedAt = Date()

        updateTotals()
        save()
        updateUndoRedoState()

        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    func undo() {
        guard let (areaCount, oldValue) = undoStack.popLast() else { return }

        redoStack.append((areaCount, areaCount.count))
        areaCount.count = oldValue
        areaCount.updatedAt = Date()

        updateTotals()
        save()
        updateUndoRedoState()
    }

    func redo() {
        guard let (areaCount, newValue) = redoStack.popLast() else { return }

        undoStack.append((areaCount, areaCount.count))
        areaCount.count = newValue
        areaCount.updatedAt = Date()

        updateTotals()
        save()
        updateUndoRedoState()
    }

    func lockEvent() {
        event.isLocked = true
        event.updatedAt = Date()
        save()
    }

    func shareReport() {
        // TODO: Implement CSV export and sharing
        // For now, just log
        print("Sharing report for event: \(event.eventName)")
    }

    private func updateTotals() {
        totalAttendance = areaCounts.reduce(0) { $0 + $1.count }
        totalCapacity = areaCounts.reduce(0) { $0 + $1.capacity }

        event.totalAttendance = totalAttendance
        event.totalCapacity = totalCapacity
        event.updatedAt = Date()
    }

    private func updateUndoRedoState() {
        canUndo = !undoStack.isEmpty
        canRedo = !redoStack.isEmpty
    }

    private func save() {
        try? modelContext?.save()
    }
}

#Preview {
    let venue = Venue(name: "Test Church", location: "Test City", code: "TC")
    let event = Event(eventName: "Sunday Service", venue: venue)
    return NavigationStack {
        CountingScreen(event: event)
            .modelContainer(for: [Event.self, AreaCount.self, AreaTemplate.self])
    }
}
