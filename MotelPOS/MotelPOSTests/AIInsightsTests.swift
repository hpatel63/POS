import XCTest
import ComposableArchitecture
@testable import MotelPOS

final class AIInsightsTests: XCTestCase {
    func testAIAssistantStreamsMessage() async {
        let insight = AIStreamEvent(text: "Insight complete", isFinal: true)
        let aiService = AIServiceMock(events: [insight], insight: AIInsight(title: "", message: "", severity: .normal))
        let store = TestStore(initialState: AIAssistantFeature.State(), reducer: { AIAssistantFeature() }) {
            $0.services = ServiceContainer(
                persistence: .shared,
                payment: PaymentServiceMock(resultToken: "tok", captureResponse: PaymentCaptureResponse(confirmationCode: "AUTH", capturedAt: Date())),
                ocr: OCRServiceMock(result: IDScanResult(firstName: "A", lastName: "B", address: Address(line1: "", line2: nil, city: "", state: "", postalCode: "", country: ""), idNumber: "", issuingState: "", expiration: Date())),
                sync: SyncServiceMock(),
                ai: aiService,
                pdf: DocumentGenerationServiceMock(),
                notification: NotificationSchedulerServiceMock()
            )
        }
        await store.send(.updateInput("How was occupancy?"))
        await store.send(.sendMessage)
        await store.receive(.receiveStream(.success(insight)))
        await store.withState { state in
            XCTAssertEqual(state.messages.last?.content, "Insight complete")
        }
    }
}
