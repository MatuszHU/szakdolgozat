import Foundation
import Combine

@K3
@MainActor
public class LoadingViewModel: ObservableObject {
    @Published public private(set) var showsLoadingScreen = false
    public private(set) var hasShownLoadingScreen = false
    private var tracker = LoadingTracker()
    private let now: () -> Date

    public init(now: @escaping () -> Date = Date.init) {
        self.now = now
    }

    public func begin() -> UUID {
        let id = tracker.begin(at: now())
        Task { [weak self] in
            try? await Task.sleep(for: .seconds(LoadingTracker.delay))
            self?.refresh()
        }
        return id
    }

    public func end(_ id: UUID) {
        tracker.end(id)
        refresh()
    }

    public func refresh() {
        showsLoadingScreen = tracker.showsLoadingScreen(at: now())
        hasShownLoadingScreen = hasShownLoadingScreen || showsLoadingScreen
    }

    public func run(_ work: () async -> Void) async {
        let id = begin()
        await work()
        end(id)
    }
}
