import SwiftUI
import SharedKit

@main
@M1 @M3
struct NightlifeApp: App {
    @StateObject private var authViewModel = AuthViewModel(store: KeychainCredentialStore(service: "hu.matusz.nightlife.guest.signin"))

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    GuestHomeView(viewModel: authViewModel)
                } else {
                    GuestWelcomeView(viewModel: authViewModel)
                }
            }
            .task {
                authViewModel.checkAuthState()
            }
        }
    }
}
