import Foundation
import ComposableArchitecture

struct RoomsFeature: Reducer {
    struct State: Equatable {
        struct DayCell: Equatable, Identifiable {
            var id: UUID { reservation?.id ?? UUID() }
            var date: Date
            var room: Room
            var reservation: Reservation?
        }

        var rooms: [Room] = SeedData.initialRooms
        var selectedPropertyID: UUID? = SeedData.initialProperties.first?.id
        var dates: [Date] = (0..<7).map { Calendar.current.date(byAdding: .day, value: $0, to: Date())! }
        var grid: [Room: [DayCell]] = [:]
        var filters = RoomFilters()
        var presentingReservation: ReservationFeature.State? = nil
        var presentingWalkIn: CheckInFeature.State? = nil
        var showingCreateBooking = false
    }

    struct RoomFilters: Equatable {
        var roomType: RoomType? = nil
        var smoking: Bool? = nil
        var floor: Int? = nil
    }

    enum Action: Equatable {
        case setProperty(UUID)
        case loadGrid
        case cellTapped(Room, Date)
        case cellDoubleTapped(Room, Date)
        case presentReservation(Reservation)
        case dismissModals
        case applyFilters(RoomFilters)
    }

    @Dependency(\.uuid) var uuid
    @Dependency(\.date) var date

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .setProperty(id):
                state.selectedPropertyID = id
                return .send(.loadGrid)
            case .loadGrid:
                let propertyRooms = SeedData.initialRooms.filter { $0.propertyID == state.selectedPropertyID }
                state.rooms = apply(filters: state.filters, to: propertyRooms)
                state.grid = Dictionary(uniqueKeysWithValues: state.rooms.map { room in
                    let cells = state.dates.map { date -> State.DayCell in
                        let reservation = Reservation(
                            id: UUID(),
                            propertyID: room.propertyID,
                            roomID: room.id,
                            guestID: UUID(),
                            status: .confirmed,
                            checkInDate: date,
                            checkOutDate: Calendar.current.date(byAdding: .day, value: 1, to: date)!,
                            nightlyRate: 125,
                            total: 125,
                            balanceDue: 0,
                            adults: 2,
                            children: 0,
                            pets: 0,
                            paymentIDs: [],
                            authorizationPacketURL: nil,
                            signatureHash: nil,
                            documents: [],
                            createdAt: self.date.now(),
                            updatedAt: self.date.now(),
                            isDeleted: false,
                            retentionUntil: nil
                        )
                        return State.DayCell(date: date, room: room, reservation: room.status == .available ? nil : reservation)
                    }
                    return (room, cells)
                })
                return .none
            case let .cellTapped(room, date):
                if let reservation = state.grid[room]?.first(where: { $0.date == date })?.reservation {
                    state.presentingReservation = ReservationFeature.State(reservation: reservation)
                } else {
                    state.presentingWalkIn = CheckInFeature.State(room: room, checkInDate: date)
                }
                return .none
            case let .cellDoubleTapped(room, date):
                state.presentingWalkIn = CheckInFeature.State(room: room, checkInDate: date)
                return .none
            case .dismissModals:
                state.presentingReservation = nil
                state.presentingWalkIn = nil
                return .none
            case let .applyFilters(filters):
                state.filters = filters
                return .send(.loadGrid)
            case .presentReservation:
                return .none
        }
    }
    }

    private func apply(filters: RoomFilters, to rooms: [Room]) -> [Room] {
        rooms.filter { room in
            var include = true
            if let type = filters.roomType {
                include = include && room.type == type
            }
            if let smoking = filters.smoking {
                include = include && room.smoking == smoking
            }
            if let floor = filters.floor {
                include = include && room.floor == floor
            }
            return include
        }
    }
}
