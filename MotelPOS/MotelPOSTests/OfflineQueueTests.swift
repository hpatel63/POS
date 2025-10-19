import XCTest
@testable import MotelPOS
import ComposableArchitecture

final class OfflineQueueTests: XCTestCase {
    func testSyncResultUpdatesState() async throws {
        let syncService = SyncServiceMock(isOnline: false, flushResult: SyncResult(pushed: 2, pulled: 1, resolvedConflicts: 1))
        let store = TestStore(initialState: OfflineFeature.State(), reducer: { OfflineFeature() }) {
            $0.services = ServiceContainer(
                persistence: .shared,
                payment: PaymentServiceMock(resultToken: "tok", captureResponse: PaymentCaptureResponse(confirmationCode: "AUTH", capturedAt: Date())),
                ocr: OCRServiceMock(result: IDScanResult(firstName: "A", lastName: "B", address: Address(line1: "", line2: nil, city: "", state: "", postalCode: "", country: ""), idNumber: "", issuingState: "", expiration: Date())),
                sync: syncService,
                ai: AIServiceMock(events: [], insight: AIInsight(title: "", message: "", severity: .normal)),
                pdf: DocumentGenerationServiceMock(),
                notification: NotificationSchedulerServiceMock()
            )
        }

        await store.send(.connectivityChanged(true)) {
            $0.isOnline = true
        }
        await store.receive(.syncNow)
        await store.receive(.syncResponse(.success(syncService.flushResult)))
    }
}
