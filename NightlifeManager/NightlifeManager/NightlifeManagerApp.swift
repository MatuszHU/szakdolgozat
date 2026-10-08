import SwiftUI
import SharedKit

@main
@L1 @L2 @L9
struct NightlifeManagerApp: App {
    @StateObject private var session = AdminSessionViewModel(
        serviceURL: UserDefaults.standard.string(forKey: AdminSessionViewModel.serviceURLKey).flatMap(URL.init(string:)),
        makeLocalBackend: {
            LocalAdminBackend(store: LocalJSONStore<AdminDirectory>(fileName: "admins.json"), hasher: PBKDF2PasswordHasher())
        })

    @L9
    static let adminGuideURL = URL(string: "https://github.com/MatuszHU/szakdolgozat/blob/master/Kieg%C3%A9sz%C3%ADt%C5%91%20Dokumentumok/adminisztratori_utmutato.md")!

    var body: some Scene {
        WindowGroup {
            AdminRootView(session: session)
        }
        .commands {
            CommandGroup(replacing: .help) {
                Link("Adminisztrátori útmutató", destination: Self.adminGuideURL)
            }
        }
    }
}
