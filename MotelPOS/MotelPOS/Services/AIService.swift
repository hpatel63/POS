import Foundation
import Combine

protocol AIService {
    func streamInsight(for prompt: AIRequest) -> AnyPublisher<AIStreamEvent, Error>
    func analyzeAnomalies(for metrics: PropertyMetrics) -> AnyPublisher<AIInsight, Error>
}

struct AIRequest: Codable, Equatable {
    var query: String
    var context: [String: String]
    var role: RoleScope

    enum RoleScope: String, Codable { case manager, associate }
}

struct AIStreamEvent: Equatable {
    var text: String
    var isFinal: Bool
}

struct AIInsight: Equatable, Codable {
    var title: String
    var message: String
    var severity: InsightSeverity
}

enum InsightSeverity: String, Codable { case normal, warning, critical }

struct PropertyMetrics: Equatable, Codable {
    var propertyID: UUID?
    var occupancy: Double
    var adr: Double
    var revPAR: Double
    var revenueMix: [Payment.Method: Decimal]
    var upcomingCheckIns: Int
    var upcomingCheckOuts: Int
    var outOfServiceRooms: Int
    var timestamp: Date
}

struct AIServiceLive: AIService {
    func streamInsight(for prompt: AIRequest) -> AnyPublisher<AIStreamEvent, Error> {
        let messages = [
            AIStreamEvent(text: "Analyzing metrics...", isFinal: false),
            AIStreamEvent(text: "Occupancy trending upward. ", isFinal: false),
            AIStreamEvent(text: "Recommend monitoring housekeeping capacity.", isFinal: true)
        ]
        return messages.publisher
            .delay(for: .milliseconds(120), scheduler: RunLoop.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func analyzeAnomalies(for metrics: PropertyMetrics) -> AnyPublisher<AIInsight, Error> {
        let occupancy = metrics.occupancy
        let message: String
        let severity: InsightSeverity
        if occupancy < 0.4 {
            message = "Occupancy dropped below 40%. Consider targeted promotions."
            severity = .warning
        } else if metrics.outOfServiceRooms > 5 {
            message = "High OOS rooms detected. Schedule maintenance review."
            severity = .critical
        } else {
            message = "KPIs within normal ranges."
            severity = .normal
        }
        let insight = AIInsight(title: "AI Insight", message: message, severity: severity)
        return Just(insight)
            .delay(for: .milliseconds(150), scheduler: RunLoop.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

struct AIServiceMock: AIService {
    var events: [AIStreamEvent]
    var insight: AIInsight

    func streamInsight(for prompt: AIRequest) -> AnyPublisher<AIStreamEvent, Error> {
        events.publisher
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func analyzeAnomalies(for metrics: PropertyMetrics) -> AnyPublisher<AIInsight, Error> {
        Just(insight)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
