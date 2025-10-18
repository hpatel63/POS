import SwiftUI
import ComposableArchitecture

struct ReportsView: View {
    let store: StoreOf<ReportsFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Picker("Report", selection: viewStore.binding(get: \.
selectedReport!, send: ReportsFeature.Action.selectReport)) {
                        ForEach(viewStore.availableReports) { report in
                            Text(report.rawValue).tag(report)
                        }
                    }
                    .pickerStyle(.segmented)
                    DatePicker("From", selection: viewStore.binding(get: \.
startDate, send: { ReportsFeature.Action.setDates($0, viewStore.endDate) }), displayedComponents: .date)
                    DatePicker("To", selection: viewStore.binding(get: \.
endDate, send: { ReportsFeature.Action.setDates(viewStore.startDate, $0) }), displayedComponents: .date)
                }
                HStack(spacing: 16) {
                    Picker("Format", selection: viewStore.binding(get: \.
exportFormat, send: ReportsFeature.Action.selectFormat)) {
                        ForEach(ReportsFeature.ExportFormat.allCases, id: \.self) { format in
                            Text(format.rawValue.uppercased()).tag(format)
                        }
                    }
                    .pickerStyle(.segmented)
                    Menu {
                        Button("All Properties") { viewStore.send(.setProperty(nil)) }
                        ForEach(SeedData.initialProperties) { property in
                            Button(property.name) { viewStore.send(.setProperty(property.id)) }
                        }
                    } label: {
                        Label(viewStore.filterPropertyID.flatMap { id in SeedData.initialProperties.first { $0.id == id }?.name } ?? "All", systemImage: "building.2")
                    }
                    TextField("Override reason", text: viewStore.binding(get: \.
managerOverrideReason, send: ReportsFeature.Action.setManagerOverride))
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 240)
                }
                HStack(spacing: 12) {
                    Button("Export") { viewStore.send(.export) }
                        .buttonStyle(.borderedProminent)
                    Button("AI Summary") { viewStore.send(.aiSummary) }
                        .buttonStyle(.bordered)
                }
                if let url = viewStore.generatedURL {
                    Text("Generated report: \(url.lastPathComponent)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                if let summary = viewStore.aiSummary {
                    Text("AI Insight: \(summary)")
                        .font(.body)
                }
                Spacer()
            }
            .padding()
            .background(.ultraThinMaterial)
        }
    }
}
