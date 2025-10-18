import Foundation
import ComposableArchitecture

struct ReportsFeature: Reducer {
    struct State: Equatable {
        var availableReports: [ReportType] = ReportType.allCases
        var selectedReport: ReportType? = .dailyClose
        var startDate: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        var endDate: Date = Date()
        var generatedURL: URL? = nil
        var filterPropertyID: UUID? = SeedData.initialProperties.first?.id
        var exportFormat: ExportFormat = .pdf
        var managerOverrideReason: String = ""
        var showAccessDeniedAlert = false
        var aiSummary: String? = nil
    }

    enum ReportType: String, CaseIterable, Identifiable {
        case dailyClose = "Daily Close"
        case taxes = "Taxes"
        case occupancy = "Occupancy & Production"
        case revenue = "Revenue"
        case paymentMix = "Payment Mix"
        case refunds = "Refunds & Chargebacks"
        case managerLog = "Manager Actions Log"
        case incidentSummary = "Incident Report by Guest"
        case damageRecovery = "Damage Cost Recovery"
        var id: String { rawValue }
    }

    enum ExportFormat: String, CaseIterable { case pdf, csv }

    enum Action: Equatable {
        case selectReport(ReportType)
        case setDates(Date, Date)
        case export
        case exportResponse(Result<URL, Error>)
        case selectFormat(ExportFormat)
        case setProperty(UUID?)
        case setManagerOverride(String)
        case aiSummary
        case aiSummaryResponse(Result<AIInsight, Error>)
    }

    @Dependency(\.services) var services

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .selectReport(report):
                state.selectedReport = report
                return .none
            case let .setDates(start, end):
                state.startDate = start
                state.endDate = end
                return .none
            case .export:
                guard let report = state.selectedReport else { return .none }
                let summary = ReportSummary(title: report.rawValue, metrics: ["Start": state.startDate.formatted(), "End": state.endDate.formatted()])
                let exportFormat = state.exportFormat
                return .run { send in
                    do {
                        let url: URL
                        switch exportFormat {
                        case .pdf:
                            url = try services.pdf.generateTaxPacket(for: SeedData.initialProperties.first!, reports: [summary])
                        case .csv:
                            url = try await generateCSV(for: summary)
                        }
                        await send(.exportResponse(.success(url)))
                    } catch {
                        await send(.exportResponse(.failure(error)))
                    }
                }
            case let .exportResponse(.success(url)):
                state.generatedURL = url
                return .none
            case .exportResponse(.failure):
                state.showAccessDeniedAlert = true
                return .none
            case let .selectFormat(format):
                state.exportFormat = format
                return .none
            case let .setProperty(id):
                state.filterPropertyID = id
                return .none
            case let .setManagerOverride(reason):
                state.managerOverrideReason = reason
                return .none
            case .aiSummary:
                return services.ai.analyzeAnomalies(for: PropertyMetrics(propertyID: state.filterPropertyID, occupancy: 0.78, adr: 125, revPAR: 102, revenueMix: [.credit: 4200], upcomingCheckIns: 9, upcomingCheckOuts: 7, outOfServiceRooms: 1, timestamp: Date()))
                    .map { .aiSummaryResponse(.success($0)) }
                    .catch { Just(.aiSummaryResponse(.failure($0))) }
                    .eraseToEffect()
            case let .aiSummaryResponse(.success(insight)):
                state.aiSummary = insight.message
                return .none
            case .aiSummaryResponse(.failure):
                state.aiSummary = "Unable to generate insight."
                return .none
            }
        }
    }

    func generateCSV(for summary: ReportSummary) async throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("report.csv")
        let header = "Metric,Value\n"
        let body = summary.metrics.map { "\($0.key),\($0.value)" }.joined(separator: "\n")
        try (header + body).write(to: url, atomically: true, encoding: .utf8)
        return url
    }
}
