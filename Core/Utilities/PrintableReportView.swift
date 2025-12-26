import SwiftUI
import SwiftData

struct PrintableReportView: View {
    let event: Event
    let venue: Venue?

    private var totalCount: Int {
        event.areaCounts.reduce(0) { $0 + $1.count }
    }

    private var totalCapacity: Int {
        event.areaCounts.reduce(0) { $0 + $1.capacity }
    }

    private var sortedAreaCounts: [AreaCount] {
        event.areaCounts.sorted { area1, area2 in
            guard let template1 = area1.areaTemplate,
                  let template2 = area2.areaTemplate else {
                return false
            }
            return template1.displayOrder < template2.displayOrder
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                headerSection

                separator()

                // Event Details
                eventDetailsSection

                separator()

                // Area Counts
                areaCountsSection

                separator()

                // Summary
                summarySection

                separator()

                // Footer
                footerSection

                Spacer()
                    .frame(height: 40)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .frame(maxWidth: 320)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }

    private var headerSection: some View {
        VStack(alignment: .center, spacing: 4) {
            Text("HEAD COUNT REPORT")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.black)

            if let venue = venue {
                Text(venue.name.uppercased())
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundColor(.black)

                if !venue.location.isEmpty {
                    Text(venue.location)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
    }

    private var eventDetailsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            receiptRow(label: "Event", value: event.eventName)
            receiptRow(label: "Date", value: formatDate(event.date))
            receiptRow(label: "Time", value: formatTime(event.date))

            if !event.countedBy.isEmpty {
                receiptRow(label: "Counted By", value: event.countedBy)
            }

            if !event.weather.isEmpty {
                receiptRow(label: "Weather", value: event.weather)
            }
        }
        .padding(.vertical, 8)
    }

    private var areaCountsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("AREA BREAKDOWN")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.black)
                .padding(.bottom, 8)

            ForEach(sortedAreaCounts) { areaCount in
                areaCountRow(areaCount: areaCount)
            }
        }
        .padding(.vertical, 8)
    }

    private func areaCountRow(areaCount: AreaCount) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(areaCount.areaTemplate?.name ?? "Unknown")
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundColor(.black)

            HStack {
                Text("Count:")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.gray)

                Spacer()

                Text("\(areaCount.count)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.black)
            }

            HStack {
                Text("Capacity:")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.gray)

                Spacer()

                Text("\(areaCount.capacity)")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.gray)

                Text("(\(formatPercentage(count: areaCount.count, capacity: areaCount.capacity)))")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.gray)
            }

            if areaCount.areaTemplate != sortedAreaCounts.last?.areaTemplate {
                dashLine()
                    .padding(.vertical, 6)
            }
        }
        .padding(.bottom, 6)
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TOTAL")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .center)

            VStack(spacing: 4) {
                HStack {
                    Text("Total Count:")
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundColor(.black)

                    Spacer()

                    Text("\(totalCount)")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(.black)
                }

                HStack {
                    Text("Total Capacity:")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.gray)

                    Spacer()

                    Text("\(totalCapacity)")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.gray)
                }

                HStack {
                    Text("Utilization:")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.gray)

                    Spacer()

                    Text(formatPercentage(count: totalCount, capacity: totalCapacity))
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.black)
                }
            }
        }
        .padding(.vertical, 8)
    }

    private var footerSection: some View {
        VStack(spacing: 4) {
            Text("Generated: \(formatDateTime(Date()))")
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(.gray)

            Text("ID: \(event.id.prefix(8))")
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(.gray)

            if !event.notes.isEmpty {
                Text("Notes:")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundColor(.black)
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(event.notes)
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 8)
    }

    private func separator() -> some View {
        Rectangle()
            .fill(Color.black)
            .frame(height: 1)
            .padding(.vertical, 2)
    }

    private func dashLine() -> some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                var x: CGFloat = 0
                while x < width {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: min(x + 4, width), y: 0))
                    x += 8
                }
            }
            .stroke(Color.gray, lineWidth: 1)
        }
        .frame(height: 1)
    }

    private func receiptRow(label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 4) {
            Text("\(label):")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.gray)
                .frame(width: 90, alignment: .leading)

            Text(value)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy HH:mm"
        return formatter.string(from: date)
    }

    private func formatPercentage(count: Int, capacity: Int) -> String {
        guard capacity > 0 else { return "N/A" }
        let percentage = Double(count) / Double(capacity) * 100
        return String(format: "%.0f%%", percentage)
    }
}

#Preview {
    @Previewable @State var previewContainer: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Event.self, AreaCount.self, Venue.self, AreaTemplate.self, configurations: config)

        let venue = Venue(
            name: "Main Church Building",
            location: "123 Main Street, City, State",
            code: "MCB"
        )
        container.mainContext.insert(venue)

        let area1 = AreaTemplate(
            name: "Main Sanctuary",
            type: .seating,
            capacity: 500,
            displayOrder: 1
        )
        let area2 = AreaTemplate(
            name: "Overflow Room",
            type: .overflow,
            capacity: 100,
            displayOrder: 2
        )
        let area3 = AreaTemplate(
            name: "Parking Lot",
            type: .parking,
            capacity: 150,
            displayOrder: 3
        )
        venue.areas.append(contentsOf: [area1, area2, area3])

        let event = Event(
            date: Date(),
            eventName: "Sunday Morning Service",
            countedBy: "John Doe",
            countedByUserId: "user123",
            notes: "Special Easter service with additional seating areas"
        )
        event.weather = "Sunny, 72°F"

        let count1 = AreaCount(count: 425, capacity: 500)
        count1.areaTemplate = area1

        let count2 = AreaCount(count: 85, capacity: 100)
        count2.areaTemplate = area2

        let count3 = AreaCount(count: 120, capacity: 150)
        count3.areaTemplate = area3

        event.areaCounts = [count1, count2, count3]
        container.mainContext.insert(event)

        return container
    }()

    let context = previewContainer.mainContext
    let events = try! context.fetch(FetchDescriptor<Event>())
    let venues = try! context.fetch(FetchDescriptor<Venue>())

    PrintableReportView(event: events.first!, venue: venues.first)
        .modelContainer(previewContainer)
}
