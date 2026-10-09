import Foundation
import Combine

@M11
public struct GuideTip: Identifiable {
    public let id: String
    public let title: LocalizedStringResource
    public let message: LocalizedStringResource
    public let symbol: String

    public init(id: String, title: LocalizedStringResource, message: LocalizedStringResource, symbol: String) {
        self.id = id
        self.title = title
        self.message = message
        self.symbol = symbol
    }
}

@M11
public protocol TipStoring {
    func seenTips() -> Set<String>
    func save(_ seen: Set<String>)
}

@M11
public struct UserDefaultsTipStore: TipStoring {
    private let defaults: UserDefaults
    private let key: String

    public init(defaults: UserDefaults = .standard, key: String = "SeenGuideTips") {
        self.defaults = defaults
        self.key = key
    }

    public func seenTips() -> Set<String> {
        Set(defaults.stringArray(forKey: key) ?? [])
    }

    public func save(_ seen: Set<String>) {
        defaults.set(seen.sorted(), forKey: key)
    }
}

@M11
public class GuideTipCenter: ObservableObject {
    @Published public private(set) var current: GuideTip?
    private let tips: [String: GuideTip]
    private let store: TipStoring
    private var seen: Set<String>

    public init(tips: [String: GuideTip], store: TipStoring) {
        self.tips = tips
        self.store = store
        seen = store.seenTips()
    }

    public func visit(_ place: String) {
        guard current == nil, let tip = tips[place], !seen.contains(tip.id) else { return }
        current = tip
    }

    public func dismiss() {
        guard let tip = current else { return }
        seen.insert(tip.id)
        store.save(seen)
        current = nil
    }

    public func reset() {
        seen = []
        store.save(seen)
    }
}
