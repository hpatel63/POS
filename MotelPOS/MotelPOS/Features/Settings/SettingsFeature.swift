import Foundation
import ComposableArchitecture

struct SettingsFeature: Reducer {
    struct State: Equatable {
        var branding = BrandingSettings()
        var payments = PaymentSettings()
        var taxes = TaxSettings()
        var users = UserSettings()
        var documents = DocumentSettings()
        var ai = AISettings()
        var retention = RetentionSettings()
    }

    struct BrandingSettings: Equatable {
        var companyName: String = "Aurora Hospitality"
        var logoURL: URL? = nil
        var address: Address = SeedData.initialProperties.first!.address
        var phone: String = "512-555-1000"
        var website: URL? = SeedData.initialProperties.first!.branding.website
    }

    struct PaymentSettings: Equatable {
        var cashAppHandle: String = "$auroramotel"
        var processor: String = "Stripe"
        var processorToken: String = ""
        var demoMode = true
    }

    struct TaxSettings: Equatable {
        var profiles: [TaxProfile] = [
            TaxProfile(id: UUID(), name: "State Tax", jurisdiction: "TX", rate: 0.06, appliesTo: ["lodging"], createdAt: Date(), updatedAt: Date(), isDeleted: false, retentionUntil: nil)
        ]
    }

    struct UserSettings: Equatable {
        var users: [User] = []
        var roles: [Role] = [Role(id: UUID(), name: "Manager", permissions: Permission.allCases)]
    }

    struct DocumentSettings: Equatable {
        var templates: [Document] = []
    }

    struct AISettings: Equatable {
        var apiKeyMasked: String = "••••-demo"
        var enabledModules: Set<AIModule> = Set(AIModule.allCases)
        var suggestiveModeEnabled = true
        var manualDocuments: [Document] = []
    }

    struct RetentionSettings: Equatable {
        var idRetentionDays: Int = 365
        var signatureRetentionDays: Int = 365
        var purgeEnabled = true
    }

    enum AIModule: String, CaseIterable, Hashable { case assistant, insights, reports, search }

    enum Action: Equatable {
        case updateBranding(BrandingSettings)
        case updatePayments(PaymentSettings)
        case updateAI(AISettings)
        case updateRetention(RetentionSettings)
        case toggleModule(AIModule)
        case save
    }

    @Dependency(\.services) var services

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .updateBranding(branding):
                state.branding = branding
                return .none
            case let .updatePayments(payments):
                state.payments = payments
                return .none
            case let .updateAI(ai):
                state.ai = ai
                return .none
            case let .updateRetention(retention):
                state.retention = retention
                return .none
            case let .toggleModule(module):
                if state.ai.enabledModules.contains(module) {
                    state.ai.enabledModules.remove(module)
                } else {
                    state.ai.enabledModules.insert(module)
                }
                return .none
            case .save:
                return .none
            }
        }
    }
}
