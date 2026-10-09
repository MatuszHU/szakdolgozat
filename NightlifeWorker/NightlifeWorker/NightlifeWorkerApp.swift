import SwiftUI
import SharedKit

@main
@K1 @K4 @K11 @K3
struct NightlifeWorkerApp: App {
    @StateObject private var authViewModel = AuthViewModel(store: KeychainCredentialStore(service: "hu.matusz.nightlife.worker.signin"))
    @StateObject private var language = LanguageSettings(store: UserDefaultsLanguageStore(), supported: AppLanguage.worker)
    @StateObject private var loading = LoadingViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    HomeView(viewModel: authViewModel, language: language)
                } else {
                    WelcomeView(viewModel: authViewModel)
                }
            }
            .overlay {
                if loading.showsLoadingScreen {
                    LoadingScreen()
                }
            }
            .animation(.easeInOut(duration: 0.2), value: loading.showsLoadingScreen)
            .environment(\.locale, language.locale)
            .environmentObject(loading)
            .task {
                await loading.run { authViewModel.checkAuthState() }
            }
        }
    }
}
