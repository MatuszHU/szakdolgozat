import Foundation

@K3
public struct LoadingTracker {
    public static let delay: TimeInterval = 0.3

    private var running: [UUID: Date] = [:]

    public init() {}

    public var isLoading: Bool { !running.isEmpty }

    @discardableResult
    public mutating func begin(at date: Date) -> UUID {
        let id = UUID()
        running[id] = date
        return id
    }

    public mutating func end(_ id: UUID) {
        running[id] = nil
    }

    public func showsLoadingScreen(at date: Date) -> Bool {
        running.values.contains { date.timeIntervalSince($0) >= Self.delay - 0.000_001 }
    }
}
