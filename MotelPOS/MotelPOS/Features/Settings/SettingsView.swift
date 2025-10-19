import SwiftUI
import ComposableArchitecture

struct SettingsView: View {
    let store: StoreOf<SettingsFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section("Branding") {
                    TextField("Company Name", text: viewStore.binding(get: \.
branding.companyName, send: { .updateBranding(SettingsFeature.BrandingSettings(companyName: $0, logoURL: viewStore.branding.logoURL, address: viewStore.branding.address, phone: viewStore.branding.phone, website: viewStore.branding.website)) }))
                    TextField("Phone", text: viewStore.binding(get: \.
branding.phone, send: { phone in
                        var branding = viewStore.branding
                        branding.phone = phone
                        return .updateBranding(branding)
                    }))
                    TextField("Website", text: viewStore.binding(get: \.
branding.website?.absoluteString ?? "", send: { urlString in
                        var branding = viewStore.branding
                        branding.website = URL(string: urlString)
                        return .updateBranding(branding)
                    }))
                }
                Section("Payments") {
                    TextField("Cash App Handle", text: viewStore.binding(get: \.
payments.cashAppHandle, send: { handle in
                        var settings = viewStore.payments
                        settings.cashAppHandle = handle
                        return .updatePayments(settings)
                    }))
                    Toggle("Demo Mode", isOn: viewStore.binding(get: \.
payments.demoMode, send: { enabled in
                        var settings = viewStore.payments
                        settings.demoMode = enabled
                        return .updatePayments(settings)
                    }))
                }
                Section("AI Integration") {
                    ForEach(SettingsFeature.AIModule.allCases, id: \.self) { module in
                        Toggle(module.rawValue.capitalized, isOn: viewStore.binding(get: { viewStore.ai.enabledModules.contains(module) }, send: { enabled in
                            .toggleModule(module)
                        }))
                    }
                    Toggle("Suggestive Mode", isOn: viewStore.binding(get: \.
ai.suggestiveModeEnabled, send: { enabled in
                        var ai = viewStore.ai
                        ai.suggestiveModeEnabled = enabled
                        return .updateAI(ai)
                    }))
                }
                Section("Retention") {
                    Stepper("ID Retention: \(viewStore.retention.idRetentionDays) days", value: viewStore.binding(get: \.
retention.idRetentionDays, send: { days in
                        var retention = viewStore.retention
                        retention.idRetentionDays = days
                        return .updateRetention(retention)
                    }), in: 30...730)
                    Toggle("Enable Auto-Purge", isOn: viewStore.binding(get: \.
retention.purgeEnabled, send: { enabled in
                        var retention = viewStore.retention
                        retention.purgeEnabled = enabled
                        return .updateRetention(retention)
                    }))
                }
                Button("Save") { viewStore.send(.save) }
                    .buttonStyle(.borderedProminent)
            }
            .scrollContentBackground(.hidden)
            .background(.ultraThinMaterial)
        }
    }
}
