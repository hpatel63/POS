import SwiftUI
import ComposableArchitecture

struct RoomsView: View {
    let store: StoreOf<RoomsFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading, spacing: 16) {
                header(viewStore: viewStore)
                ScrollView([.horizontal, .vertical]) {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(viewStore.rooms, id: \.
id) { room in
                            roomRow(room: room, viewStore: viewStore)
                        }
                    }
                    .padding()
                }
            }
            .background(Color.black.opacity(0.7))
            .sheet(item: viewStore.binding(get: \.
presentingReservation, send: { _ in .dismissModals })) { state in
                ReservationView(store: Store(initialState: state, reducer: { ReservationFeature() }))
            }
            .sheet(item: viewStore.binding(get: \.
presentingWalkIn, send: { _ in .dismissModals })) { state in
                CheckInView(store: Store(initialState: state, reducer: { CheckInFeature() }))
            }
            .onAppear { viewStore.send(.loadGrid) }
        }
    }

    private func header(viewStore: ViewStoreOf<RoomsFeature>) -> some View {
        HStack {
            Menu {
                ForEach(SeedData.initialProperties) { property in
                    Button(property.name) { viewStore.send(.setProperty(property.id)) }
                }
            } label: {
                Label(SeedData.initialProperties.first { $0.id == viewStore.selectedPropertyID }?.name ?? "All", systemImage: "building.2")
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
            }
            Spacer()
            Menu("Filters") {
                Button("All Room Types") { viewStore.send(.applyFilters(RoomsFeature.RoomFilters())) }
                ForEach(RoomType.allCases, id: \.self) { type in
                    Button(type.rawValue.capitalized) {
                        viewStore.send(.applyFilters(RoomsFeature.RoomFilters(roomType: type)))
                    }
                }
                Button("Non-smoking") {
                    viewStore.send(.applyFilters(RoomsFeature.RoomFilters(roomType: nil, smoking: false)))
                }
                Button("Smoking") {
                    viewStore.send(.applyFilters(RoomsFeature.RoomFilters(roomType: nil, smoking: true)))
                }
            }
            .padding(12)
            .background(.ultraThinMaterial)
            .cornerRadius(16)
        }
        .padding([.horizontal, .top])
    }

    private func roomRow(room: Room, viewStore: ViewStoreOf<RoomsFeature>) -> some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(room.number)
                    .font(.title3.bold())
                Text(room.type.rawValue.capitalized)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 120, alignment: .leading)
            LazyHGrid(rows: [GridItem(.fixed(70))], spacing: 16) {
                ForEach(viewStore.dates, id: \.self) { date in
                    let cell = viewStore.grid[room]?.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) })
                    roomCell(cell: cell, viewStore: viewStore)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }

    private func roomCell(cell: RoomsFeature.State.DayCell?, viewStore: ViewStoreOf<RoomsFeature>) -> some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE\nMM/dd"
        let status = cell?.room.status ?? .available
        let color: Color
        switch status {
        case .available: color = .green.opacity(0.3)
        case .occupied: color = .blue.opacity(0.5)
        case .dirty: color = .orange.opacity(0.5)
        case .outOfService: color = .red.opacity(0.5)
        }
        return VStack {
            Text(dateFormatter.string(from: cell?.date ?? Date()))
                .font(.caption2)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            Spacer()
            Text(status.rawValue.uppercased())
                .font(.caption.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .padding(12)
        .frame(width: 120, height: 80)
        .background(color)
        .cornerRadius(16)
        .onTapGesture { if let cell { viewStore.send(.cellTapped(cell.room, cell.date)) } }
        .onTapGesture(count: 2) { if let cell { viewStore.send(.cellDoubleTapped(cell.room, cell.date)) } }
        .accessibilityLabel("\(cell?.room.number ?? "") status \(status.rawValue)")
    }
}
