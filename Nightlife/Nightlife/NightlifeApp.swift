import SwiftUI
import SharedKit

@main
@M1 @M3 @M9 @M10 @M11
struct NightlifeApp: App {
    @StateObject private var authViewModel = AuthViewModel(store: KeychainCredentialStore(service: "hu.matusz.nightlife.guest.signin"))
    @StateObject private var loading = LoadingViewModel()
    @StateObject private var tips = GuideTipCenter.guest(store: UserDefaultsTipStore())
    @StateObject private var language = LanguageSettings(store: UserDefaultsLanguageStore(), supported: AppLanguage.guest)

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    GuestHomeView(viewModel: authViewModel, language: language)
                } else {
                    GuestWelcomeView(viewModel: authViewModel)
                }
            }
            .overlay {
                if loading.showsLoadingScreen {
                    LoadingScreen()
                }
            }
            .animation(.easeInOut(duration: 0.2), value: loading.showsLoadingScreen)
            .environment(\.locale, language.locale)
            .guideTips(tips)
            .environmentObject(loading)
            .environmentObject(tips)
            .task {
                await loading.run { authViewModel.checkAuthState() }
            }
        }
    }
}
