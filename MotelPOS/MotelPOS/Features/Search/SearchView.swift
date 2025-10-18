import SwiftUI
import ComposableArchitecture

struct SearchView: View {
    let store: StoreOf<SearchFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    TextField("Search guests, reservations, payments", text: viewStore.binding(get: \.
query, send: SearchFeature.Action.updateQuery))
                        .textFieldStyle(.roundedBorder)
                        .keyboardShortcut("f", modifiers: .command)
                    Button("Search") { viewStore.send(.search) }
                        .buttonStyle(.borderedProminent)
                }
                if viewStore.offlineResults {
                    Label("Offline-ready results", systemImage: "antenna.radiowaves.left.and.right.slash")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                List(viewStore.results) { result in
                    VStack(alignment: .leading) {
                        Text(result.title)
                            .font(.headline)
                        Text(result.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .onAppear { }
        }
    }
}
