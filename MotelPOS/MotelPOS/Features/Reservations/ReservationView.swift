import SwiftUI
import ComposableArchitecture

struct ReservationView: View {
    let store: StoreOf<ReservationFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                Form {
                    Section("Guest") {
                        Text("Reservation ID: \(viewStore.reservation.id.uuidString)")
                        Text("Status: \(viewStore.reservation.status.rawValue.capitalized)")
                    }
                    Section("Stay") {
                        Text("Check-in: \(viewStore.reservation.checkInDate.formatted(date: .abbreviated, time: .omitted))")
                        Text("Check-out: \(viewStore.reservation.checkOutDate.formatted(date: .abbreviated, time: .omitted))")
                        Text("Nightly rate: $\(viewStore.reservation.nightlyRate as NSDecimalNumber)")
                    }
                    Section("Payments") {
                        ForEach(viewStore.payments, id: \.id) { payment in
                            HStack {
                                Text(payment.method.rawValue.capitalized)
                                Spacer()
                                Text("$\(payment.amount as NSDecimalNumber)")
                            }
                        }
                        Button("Export Folio") { viewStore.send(.exportFolio) }
                        Button("Export Authorization") { viewStore.send(.exportAuthorization) }
                    }
                    Section("AI Suggestions") {
                        if viewStore.aiSuggestions.isEmpty {
                            Text("Tap Generate to request insights")
                        }
                        ForEach(viewStore.aiSuggestions, id: \.message) { insight in
                            VStack(alignment: .leading) {
                                Text(insight.title)
                                    .font(.headline)
                                Text(insight.message)
                            }
                        }
                        Button("Generate Suggestions") { viewStore.send(.aiSuggest) }
                            .buttonStyle(.borderedProminent)
                    }
                }
                .navigationTitle("Reservation")
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Done") { viewStore.send(.close) } } }
                .onAppear { viewStore.send(.load) }
            }
        }
    }
}
