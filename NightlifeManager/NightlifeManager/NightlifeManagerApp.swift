import SwiftUI
import SharedKit

@main
@L1 @L2
struct NightlifeManagerApp: App {
    @StateObject private var session: AdminSessionViewModel = {
        let store = LocalJSONStore<AdminDirectory>(fileName: "admins.json")
        return AdminSessionViewModel(directory: store.load() ?? AdminDirectory(), store: store,
                                     hasher: PBKDF2PasswordHasher())
    }()

    var body: some Scene {
        WindowGroup {
            AdminRootView(session: session)
        }
    }
}
