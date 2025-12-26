import SwiftUI
import UIKit

@MainActor
class PDFGenerator {
    static func generatePDF<Content: View>(from view: Content, fileName: String = "report.pdf") -> URL? {
        let renderer = ImageRenderer(content: view)

        // Set the scale to 2x for better quality
        renderer.scale = 2.0

        // Receipt size: 320pt width, dynamic height based on content
        // Using standard thermal receipt width (80mm = ~227pt, but using 320pt for readability)
        let pageSize = CGSize(width: 320, height: 1000)
        renderer.proposedSize = ProposedViewSize(pageSize)

        // Create a temporary file URL
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(fileName)

        // Get the actual rendered size
        guard let cgImage = renderer.cgImage else {
            print("Failed to render image")
            return nil
        }

        let imageHeight = CGFloat(cgImage.height) / renderer.scale
        let pdfSize = CGSize(width: 320, height: imageHeight)
        var pdfBox = CGRect(origin: .zero, size: pdfSize)

        // Create PDF context
        guard let pdfContext = CGContext(fileURL as CFURL, mediaBox: &pdfBox, nil) else {
            print("Failed to create PDF context")
            return nil
        }

        // Begin PDF page
        pdfContext.beginPDFPage(nil)

        // Render the view
        pdfContext.draw(cgImage, in: pdfBox)

        // End PDF page
        pdfContext.endPDFPage()
        pdfContext.closePDF()

        return fileURL
    }
}

// UIKit ShareSheet wrapper for SwiftUI
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
