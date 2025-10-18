import SwiftUI
import ComposableArchitecture

struct PaymentView: View {
    let store: StoreOf<PaymentFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Form {
                Section("Method") {
                    Picker("Method", selection: viewStore.binding(get: \.
method, send: PaymentFeature.Action.setMethod)) {
                        ForEach(Payment.Method.allCases, id: \.self) { method in
                            Text(method.rawValue.capitalized).tag(method)
                        }
                    }
                }
                Section("Capture") {
                    Text("Amount: $\(viewStore.amount as NSDecimalNumber)")
                    Button("Capture Payment") { viewStore.send(.capture) }
                        .buttonStyle(.borderedProminent)
                }
                if let confirmation = viewStore.confirmation {
                    Text("Confirmation: \(confirmation.confirmationCode)")
                }
                if let error = viewStore.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
        }
    }
}
