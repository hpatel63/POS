import SwiftUI
import ComposableArchitecture

struct OfflineStatusBanner: View {
    let store: StoreOf<OfflineFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack(spacing: 8) {
                Circle()
                    .fill(viewStore.isOnline ? Color.green : Color.red)
                    .frame(width: 12, height: 12)
                Text(viewStore.isOnline ? "Online" : "Offline")
                    .font(.footnote.bold())
                if let lastSync = viewStore.lastSync {
                    Text("Last sync: \(lastSync, style: .time)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(8)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
        }
    }
}
