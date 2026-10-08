import SwiftUI
import SharedKit

@main
@K1 @K4
struct NightlifeWorkerApp: App {
    @StateObject private var authViewModel = AuthViewModel(store: KeychainCredentialStore())

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    HomeView(viewModel: authViewModel)
                } else {
                    WelcomeView(viewModel: authViewModel)
                }
            }
            .task {
                authViewModel.checkAuthState()
            }
        }
    }
}
