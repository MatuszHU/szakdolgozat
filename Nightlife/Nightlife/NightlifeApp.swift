import SwiftUI
import SharedKit

@main
@M1 @M3 @M9
struct NightlifeApp: App {
    @StateObject private var authViewModel = AuthViewModel(store: KeychainCredentialStore(service: "hu.matusz.nightlife.guest.signin"))
    @StateObject private var loading = LoadingViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    GuestHomeView(viewModel: authViewModel)
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
            .environmentObject(loading)
            .task {
                await loading.run { authViewModel.checkAuthState() }
            }
        }
    }
}
