import Foundation
import Combine
import SharedKit

@K3
@MainActor
class LoadingViewModel: ObservableObject {
    @Published private(set) var showsLoadingScreen = false
    private(set) var hasShownLoadingScreen = false
    private var tracker = LoadingTracker()
    private let now: () -> Date

    init(now: @escaping () -> Date = Date.init) {
        self.now = now
    }

    func begin() -> UUID {
        let id = tracker.begin(at: now())
        Task { [weak self] in
            try? await Task.sleep(for: .seconds(LoadingTracker.delay))
            self?.refresh()
        }
        return id
    }

    func end(_ id: UUID) {
        tracker.end(id)
        refresh()
    }

    func refresh() {
        showsLoadingScreen = tracker.showsLoadingScreen(at: now())
        hasShownLoadingScreen = hasShownLoadingScreen || showsLoadingScreen
    }

    func run(_ work: () async -> Void) async {
        let id = begin()
        await work()
        end(id)
    }
}
