import SwiftUI
import ComposableArchitecture

struct DashboardView: View {
    let store: StoreOf<DashboardFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    propertySelector(viewStore: viewStore)
                    kpiGrid(viewStore: viewStore)
                    insights(viewStore: viewStore)
                    naturalLanguageQuery(viewStore: viewStore)
                }
                .padding()
            }
            .background(
                LinearGradient(colors: [Color.black.opacity(0.9), Color(red: 0.06, green: 0.1, blue: 0.2)], startPoint: .top, endPoint: .bottom)
            )
            .onAppear { viewStore.send(.loadKPIs) }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Run Query") { viewStore.send(.submitQuery) }
                        .keyboardShortcut(.return, modifiers: .command)
                }
            }
            .animation(.spring(response: 0.8, dampingFraction: 0.75), value: viewStore.aiEvents)
        }
    }

    private func propertySelector(viewStore: ViewStoreOf<DashboardFeature>) -> some View {
        VStack(alignment: .leading) {
            Text("Properties")
                .font(.title2.weight(.semibold))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewStore.properties) { property in
                        Button(action: { viewStore.send(.selectProperty(property.id)) }) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(property.name)
                                        .font(.headline)
                                    Spacer()
                                    if viewStore.selectedPropertyID == property.id {
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundStyle(.cyan)
                                    }
                                }
                                Text(property.address.city + ", " + property.address.state)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .frame(width: 240)
                            .background(.ultraThinMaterial)
                            .cornerRadius(18)
                            .overlay(RoundedRectangle(cornerRadius: 18).stroke(viewStore.selectedPropertyID == property.id ? Color.cyan : Color.clear, lineWidth: 2))
                            .shadow(color: .cyan.opacity(0.2), radius: 12, y: 6)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func kpiGrid(viewStore: ViewStoreOf<DashboardFeature>) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
            ForEach(viewStore.kpis) { kpi in
                Button(action: { viewStore.send(.fetchInsight) }) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(kpi.title)
                            .font(.headline)
                        Text(kpi.value)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.cyan)
                        Text(kpi.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(LinearGradient(colors: [Color.cyan.opacity(0.25), Color.blue.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .cornerRadius(24)
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.cyan.opacity(0.4), lineWidth: 1.5))
                }
                .buttonStyle(.plain)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(kpi.title) \(kpi.value)")
            }
        }
    }

    private func insights(viewStore: ViewStoreOf<DashboardFeature>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Daily Insight", systemImage: "sparkles")
                .font(.title2)
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.cyan.opacity(0.3), lineWidth: 1))
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(viewStore.aiEvents.enumerated()), id: \.
offset) { index, event in
                        Text(event.text)
                            .font(index == viewStore.aiEvents.count - 1 && !event.isFinal ? .headline : .body)
                            .foregroundStyle(event.isFinal ? .primary : .secondary)
                            .transition(.opacity)
                    }
                    if viewStore.isStreamingInsight {
                        ProgressView().tint(.cyan)
                    }
                    ForEach(viewStore.alerts, id: \.
message) { alert in
                        HStack {
                            Image(systemName: alert.severity == .critical ? "exclamationmark.triangle.fill" : "bolt.fill")
                                .foregroundStyle(alert.severity == .critical ? Color.red : Color.cyan)
                            Text(alert.message)
                                .font(.subheadline)
                        }
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func naturalLanguageQuery(viewStore: ViewStoreOf<DashboardFeature>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ask anything")
                .font(.headline)
            HStack {
                TextField("What was yesterday's net revenue?", text: viewStore.binding(get: \.
query, send: DashboardFeature.Action.updateQuery))
                    .textFieldStyle(.roundedBorder)
                    .keyboardShortcut("f", modifiers: .command)
                Button(action: { viewStore.send(.submitQuery) }) {
                    Label("Ask", systemImage: "paperplane")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.thinMaterial)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.cyan, lineWidth: 1))
                }
            }
        }
    }
}
