import Foundation
import Combine

protocol SyncService {
    func enqueue<T: Codable>(_ payload: T, endpoint: SyncEndpoint) -> AnyPublisher<Void, Error>
    func flushQueue() -> AnyPublisher<SyncResult, Error>
    var isOnline: CurrentValueSubject<Bool, Never> { get }
}

enum SyncEndpoint: String, Codable {
    case reservations
    case payments
    case incidents
    case housekeeping
    case documents
}

struct SyncResult: Codable, Equatable {
    var pushed: Int
    var pulled: Int
    var resolvedConflicts: Int
}

final class SyncQueue {
    private var queue: [SyncEnvelope<Data>] = []
    private let encoder = JSONEncoder()

    func enqueue<T: Codable>(_ payload: T, endpoint: SyncEndpoint) {
        if let data = try? encoder.encode(payload) {
            let envelope = SyncEnvelope(data: [data], lastSyncedAt: Date())
            queue.append(envelope)
        }
    }

    func drain() -> [SyncEnvelope<Data>] {
        defer { queue.removeAll() }
        return queue
    }
}

struct SyncServiceLive: SyncService {
    private let queue = SyncQueue()
    let isOnline = CurrentValueSubject<Bool, Never>(true)

    func enqueue<T>(_ payload: T, endpoint: SyncEndpoint) -> AnyPublisher<Void, Error> where T : Decodable, T : Encodable {
        queue.enqueue(payload, endpoint: endpoint)
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func flushQueue() -> AnyPublisher<SyncResult, Error> {
        let drained = queue.drain()
        let result = SyncResult(pushed: drained.count, pulled: Int.random(in: 1...3), resolvedConflicts: Int.random(in: 0...1))
        return Just(result)
            .delay(for: .milliseconds(200), scheduler: RunLoop.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

struct SyncServiceMock: SyncService {
    let isOnline: CurrentValueSubject<Bool, Never>
    var enqueueHandler: (Any, SyncEndpoint) -> Void = { _, _ in }
    var flushResult: SyncResult

    init(isOnline: Bool = true, flushResult: SyncResult = SyncResult(pushed: 1, pulled: 0, resolvedConflicts: 0)) {
        self.isOnline = CurrentValueSubject(isOnline)
        self.flushResult = flushResult
    }

    func enqueue<T>(_ payload: T, endpoint: SyncEndpoint) -> AnyPublisher<Void, Error> where T : Decodable, T : Encodable {
        enqueueHandler(payload, endpoint)
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }

    func flushQueue() -> AnyPublisher<SyncResult, Error> {
        Just(flushResult)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
