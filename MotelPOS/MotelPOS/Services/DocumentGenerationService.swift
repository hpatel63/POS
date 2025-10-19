import Foundation
import PDFKit
import UIKit

protocol DocumentGenerationService {
    func generateReceipt(for reservation: Reservation, property: Property, payments: [Payment]) throws -> URL
    func generateTaxPacket(for property: Property, reports: [ReportSummary]) throws -> URL
    func generateDailyClose(for property: Property, data: DailyCloseData) throws -> URL
}

struct ReportSummary: Codable, Equatable {
    var title: String
    var metrics: [String: String]
}

struct DailyCloseData: Codable, Equatable {
    var totals: [Payment.Method: Decimal]
    var netSales: Decimal
    var drawerVariance: Decimal
    var generatedAt: Date
}

struct DocumentGenerationServiceLive: DocumentGenerationService {
    func generateReceipt(for reservation: Reservation, property: Property, payments: [Payment]) throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("receipt-\(reservation.id).pdf")
        let pdfDocument = PDFDocument()
        let page = PDFPage(image: renderPDFImage(title: "Receipt", body: "Reservation #\(reservation.id.uuidString.prefix(8))"))
        pdfDocument.insert(page!, at: 0)
        pdfDocument.write(to: url)
        return url
    }

    func generateTaxPacket(for property: Property, reports: [ReportSummary]) throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("taxpacket-\(property.id).pdf")
        let pdfDocument = PDFDocument()
        let page = PDFPage(image: renderPDFImage(title: "Tax Packet", body: reports.map { "\($0.title): \($0.metrics.description)" }.joined(separator: "\n")))
        pdfDocument.insert(page!, at: 0)
        pdfDocument.write(to: url)
        return url
    }

    func generateDailyClose(for property: Property, data: DailyCloseData) throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("dailyclose-\(property.id).pdf")
        let pdfDocument = PDFDocument()
        let body = "Net Sales: $\(data.netSales)\nDrawer Variance: $\(data.drawerVariance)"
        let page = PDFPage(image: renderPDFImage(title: "Daily Close", body: body))
        pdfDocument.insert(page!, at: 0)
        pdfDocument.write(to: url)
        return url
    }

    private func renderPDFImage(title: String, body: String) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 612, height: 792))
        return renderer.image { ctx in
            UIColor.black.setFill()
            ctx.fill(CGRect(origin: .zero, size: CGSize(width: 612, height: 792)))
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.cyan
            ]
            title.draw(at: CGPoint(x: 40, y: 40), withAttributes: titleAttributes)
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor.white
            ]
            body.draw(in: CGRect(x: 40, y: 100, width: 532, height: 600), withAttributes: bodyAttributes)
        }
    }
}

struct DocumentGenerationServiceLiveError: Error {}

struct DocumentGenerationServiceMock: DocumentGenerationService {
    func generateReceipt(for reservation: Reservation, property: Property, payments: [Payment]) throws -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("mock-receipt.pdf")
    }

    func generateTaxPacket(for property: Property, reports: [ReportSummary]) throws -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("mock-taxpacket.pdf")
    }

    func generateDailyClose(for property: Property, data: DailyCloseData) throws -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("mock-dailyclose.pdf")
    }
}
