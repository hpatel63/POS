# MotelPOS iPad App

Production-grade SwiftUI + TCA iPadOS 17+ application for multi-property motel/hotel POS and light PMS.

## Architecture
- SwiftUI, Combine, The Composable Architecture (TCA)
- Modular features: Dashboard, Rooms, Reports, Settings, Reservations/Check-In, Payments, Housekeeping, Search, Offline, AI Copilot
- Core Data offline cache with background SyncEngine
- Services: Payment, OCR, Sync, AI (ChatGPT), Document/PDF generation, Notification scheduler
- Security: Keychain usage planned for API secrets, data minimization, AES-256 at rest (handled via iOS), TLS in transit

## Requirements
- Xcode 15+, iPadOS 17 SDK
- SwiftPM dependency: [pointfreeco/swift-composable-architecture](https://github.com/pointfreeco/swift-composable-architecture)
- Enable background fetch and push notifications for production build

## Setup
1. Open `MotelPOS.xcodeproj` in Xcode.
2. Run `pod install` is **not** required; dependencies resolved via SwiftPM.
3. Configure signing for the `MotelPOS` target.
4. Set the scheme to `MotelPOS` and build.

### ChatGPT API Key
Store the OpenAI API key securely in the iOS Keychain via the Settings > AI Integration screen. The sample app uses a mock AI service; wire real calls in `AIServiceLive` using the OpenAI API and ensure Secure Enclave protection with `kSecAttrAccessibleAfterFirstUnlock`.

### Cash App QR
Enter the Cash App handle under Settings > Payments. The payment service generates a QR URL that can be rendered via `QRCodeView` (implement in production to render image).

### External Processor
Populate payment processor token fields for Stripe/Square integrations. The live payment service is mocked; swap with real gateway SDK.

## Offline Sync
- `OfflineFeature` monitors reachability and drains the sync queue with timestamp conflict resolution (server wins).
- `SyncService` queues payloads while offline; flushes when connectivity restored.

## AI Copilot
- Floating chat button opens `AIAssistantView` backed by ChatGPT streaming responses.
- Dashboard includes AI anomaly detection and natural language queries.
- All AI calls redact PII fields before sending.

## Reports
- Export PDF via PDFKit templates and CSV generation for finance and compliance.
- “Tax Season Packet” aggregator uses `DocumentGenerationService`.

## Testing
Run unit tests:
```bash
xcodebuild test -scheme MotelPOS -destination 'platform=iOS Simulator,name=iPad (10th generation)'
```

Tests cover pricing/taxes, RBAC permissions, offline sync queue, AI insights, and report CSV exports.

## CI
Fastlane lane provided in `Fastlane/Fastfile`. GitHub Action workflow `ci.yml` builds and tests the project on macOS runners.

## Privacy & Compliance
- No payment PAN stored locally; tokens only.
- ID scans and signatures encrypted locally; retention policies configurable in Settings.
- Audit logging for AI queries and manager overrides enforced in features.

## Demo Mode
Toggle Demo Mode in Settings to disable real payment captures and use seeded data (two sample properties, 20 rooms each).

## Seed Data
`SeedData` populates Core Data with demo properties/rooms. Additional data may be imported via JSON file `Resources/seed.json`.

## API Contracts
Refer to `Docs/APIContracts.md` for REST + GraphQL definitions, rate limits, and security notes.
