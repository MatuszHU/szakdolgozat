import SwiftUI
import SharedKit

@main
@K1 @K4 @K11
struct NightlifeWorkerApp: App {
    @StateObject private var authViewModel = AuthViewModel(store: KeychainCredentialStore(service: "hu.matusz.nightlife.worker.signin"))
    @StateObject private var language = LanguageSettings(store: UserDefaultsLanguageStore())

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    HomeView(viewModel: authViewModel, language: language)
                } else {
                    WelcomeView(viewModel: authViewModel)
                }
            }
            .environment(\.locale, language.locale)
            .task {
                authViewModel.checkAuthState()
            }
        }
    }
}
