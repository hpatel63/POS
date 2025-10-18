import SwiftUI
import ComposableArchitecture

struct HousekeepingView: View {
    let store: StoreOf<HousekeepingFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Housekeeping")
                        .font(.largeTitle.bold())
                    Spacer()
                    Button("AI Summary") { viewStore.send(.aiSummary) }
                        .buttonStyle(.bordered)
                }
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewStore.rooms, id: \.
id) { room in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Room \(room.number)")
                                        .font(.headline)
                                    Text(room.status.rawValue.capitalized)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Picker("Status", selection: Binding(get: { room.status }, set: { newStatus in
                                    var updated = room
                                    updated.status = newStatus
                                    viewStore.send(.toggleRoom(updated))
                                })) {
                                    ForEach(RoomStatus.allCases, id: \.self) { status in
                                        Text(status.rawValue.capitalized).tag(status)
                                    }
                                }
                                .pickerStyle(.menu)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(16)
                        }
                    }
                }
                Text("Tasks")
                    .font(.title2.bold())
                ForEach(viewStore.tasks) { task in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Room \(task.roomNumber)")
                                .font(.headline)
                            Text(task.description)
                                .font(.subheadline)
                            Text(task.dueDate, style: .time)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: Binding(get: { task.completed }, set: { _ in viewStore.send(.toggleTask(task.id)) }))
                            .toggleStyle(.switch)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                }
                if let summary = viewStore.aiSummary {
                    Text("AI: \(summary)")
                        .font(.body)
                }
                Spacer()
            }
            .padding()
        }
    }
}
