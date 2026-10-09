import Foundation
import Testing
@testable import SharedKit

@K11 @M10
final class MemoryLanguageStore: LanguageStoring {
    var saved: AppLanguage?

    init(saved: AppLanguage? = nil) {
        self.saved = saved
    }

    func load() -> AppLanguage? { saved }
    func save(_ language: AppLanguage) { saved = language }
}

@Suite("Language settings")
@K11 @M10
struct LanguageSettingsTests {

    @Test func theWorkerAppHasThreeLanguagesAndTheGuestAppEight() {
        #expect(AppLanguage.worker.compactMap(\.locale).map(\.identifier) == ["hu", "en", "pt-PT"])
        #expect(AppLanguage.guest.compactMap(\.locale).map(\.identifier)
                == ["hu", "en", "de", "pt-PT", "sk", "ro", "hr", "uk"])
    }

    @Test func thePhoneLanguageIsTheDefault() {
        let settings = LanguageSettings(store: MemoryLanguageStore(), supported: AppLanguage.guest)
        #expect(settings.language == .system)
    }

    @Test func aChosenLanguageIsSaved() {
        let store = MemoryLanguageStore()
        let settings = LanguageSettings(store: store, supported: AppLanguage.guest)
        settings.choose(.ukrainian)
        #expect(settings.language == .ukrainian)
        #expect(store.saved == .ukrainian)
        #expect(LanguageSettings(store: store, supported: AppLanguage.guest).language == .ukrainian)
    }

    @Test func anUnsupportedLanguageCannotBeChosen() {
        let store = MemoryLanguageStore()
        let settings = LanguageSettings(store: store, supported: AppLanguage.worker)
        settings.choose(.german)
        #expect(settings.language == .system)
        #expect(store.saved == nil)
    }

    @Test func anUnsupportedSavedLanguageFallsBackToThePhoneLanguage() {
        let settings = LanguageSettings(store: MemoryLanguageStore(saved: .slovak), supported: AppLanguage.worker)
        #expect(settings.language == .system)
    }

    @Test func everyLanguageHasItsOwnName() {
        #expect(AppLanguage.guest.compactMap(\.nativeName)
                == ["Magyar", "English", "Deutsch", "Português (Portugal)", "Slovenčina", "Română", "Hrvatski", "Українська"])
    }
}
