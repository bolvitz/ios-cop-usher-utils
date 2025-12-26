import SwiftUI

struct ReportReceiptScreen: View {
    let event: Event
    let venue: Venue?
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    @State private var pdfURL: URL?

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()

                PrintableReportView(event: event, venue: venue)
            }
            .navigationTitle("Report Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        generateAndSharePDF()
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = pdfURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }

    private func generateAndSharePDF() {
        Task { @MainActor in
            let reportView = PrintableReportView(event: event, venue: venue)

            let fileName = "HeadCount_\(event.eventName.replacingOccurrences(of: " ", with: "_"))_\(formatDateForFileName(event.date)).pdf"

            if let url = PDFGenerator.generatePDF(from: reportView, fileName: fileName) {
                pdfURL = url
                showShareSheet = true
            }
        }
    }

    private func formatDateForFileName(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

#Preview {
    let venue = Venue(
        name: "Test Church",
        location: "123 Main St",
        code: "TC"
    )

    let event = Event(
        date: Date(),
        eventName: "Sunday Service",
        countedBy: "John Doe",
        countedByUserId: "user123"
    )

    ReportReceiptScreen(event: event, venue: venue)
        .modelContainer(for: [Event.self, Venue.self])
}
