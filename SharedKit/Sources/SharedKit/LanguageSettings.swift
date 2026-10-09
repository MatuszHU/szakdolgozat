import Foundation
import Combine

@K11 @M10
public enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case system
    case hungarian = "hu"
    case english = "en"
    case german = "de"
    case portuguese = "pt-PT"
    case slovak = "sk"
    case romanian = "ro"
    case croatian = "hr"
    case ukrainian = "uk"

    public static let worker: [AppLanguage] = [.system, .hungarian, .english, .portuguese]
    public static let guest: [AppLanguage] = allCases

    public var id: Self { self }

    public var locale: Locale? {
        self == .system ? nil : Locale(identifier: rawValue)
    }

    public var nativeName: String? {
        switch self {
        case .system: return nil
        case .hungarian: return "Magyar"
        case .english: return "English"
        case .german: return "Deutsch"
        case .portuguese: return "Português (Portugal)"
        case .slovak: return "Slovenčina"
        case .romanian: return "Română"
        case .croatian: return "Hrvatski"
        case .ukrainian: return "Українська"
        }
    }
}

@K11 @M10
public protocol LanguageStoring {
    func load() -> AppLanguage?
    func save(_ language: AppLanguage)
}

@K11 @M10
public struct UserDefaultsLanguageStore: LanguageStoring {
    private let defaults: UserDefaults
    private let key: String

    public init(defaults: UserDefaults = .standard, key: String = "AppLanguage") {
        self.defaults = defaults
        self.key = key
    }

    public func load() -> AppLanguage? {
        defaults.string(forKey: key).flatMap(AppLanguage.init(rawValue:))
    }

    public func save(_ language: AppLanguage) {
        defaults.set(language.rawValue, forKey: key)
    }
}

@K11 @M10
public class LanguageSettings: ObservableObject {
    @Published public private(set) var language: AppLanguage
    public let supported: [AppLanguage]
    private let store: LanguageStoring

    public init(store: LanguageStoring, supported: [AppLanguage]) {
        self.store = store
        self.supported = supported
        let saved = store.load() ?? .system
        language = supported.contains(saved) ? saved : .system
    }

    public var locale: Locale { language.locale ?? .autoupdatingCurrent }

    public func choose(_ language: AppLanguage) {
        guard supported.contains(language) else { return }
        self.language = language
        store.save(language)
    }

    public func text(_ resource: LocalizedStringResource) -> String {
        var resource = resource
        resource.locale = locale
        return String(localized: resource)
    }
}
