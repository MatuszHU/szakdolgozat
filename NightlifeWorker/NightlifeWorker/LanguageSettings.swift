import Foundation
import Combine
import SharedKit

@K11
enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case hungarian = "hu"
    case english = "en"
    case portuguese = "pt-PT"

    var id: Self { self }

    var locale: Locale? {
        self == .system ? nil : Locale(identifier: rawValue)
    }

    var nativeName: String? {
        switch self {
        case .system: return nil
        case .hungarian: return "Magyar"
        case .english: return "English"
        case .portuguese: return "Português (Portugal)"
        }
    }
}

@K11
protocol LanguageStoring {
    func load() -> AppLanguage?
    func save(_ language: AppLanguage)
}

@K11
struct UserDefaultsLanguageStore: LanguageStoring {
    var defaults = UserDefaults.standard
    var key = "AppLanguage"

    func load() -> AppLanguage? {
        defaults.string(forKey: key).flatMap(AppLanguage.init(rawValue:))
    }

    func save(_ language: AppLanguage) {
        defaults.set(language.rawValue, forKey: key)
    }
}

@K11
class LanguageSettings: ObservableObject {
    @Published private(set) var language: AppLanguage
    private let store: LanguageStoring

    init(store: LanguageStoring) {
        self.store = store
        language = store.load() ?? .system
    }

    var locale: Locale { language.locale ?? .autoupdatingCurrent }

    func choose(_ language: AppLanguage) {
        self.language = language
        store.save(language)
    }

    func text(_ resource: LocalizedStringResource) -> String {
        var resource = resource
        resource.locale = locale
        return String(localized: resource)
    }
}
