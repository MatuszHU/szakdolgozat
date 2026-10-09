import Foundation
import Combine
import SharedKit

@M8
enum GuestSettingsItem: CaseIterable, Identifiable {
    case profilePicture
    case about
    case signOut

    var id: Self { self }
}

@M8 @M6
class GuestSettingsViewModel: ObservableObject {
    let guestName: String?
    private let auth: AuthViewModel

    init(auth: AuthViewModel, guestName: String?) {
        self.auth = auth
        self.guestName = guestName
    }

    var items: [GuestSettingsItem] { GuestSettingsItem.allCases }

    var version: String {
        let info = Bundle.main.infoDictionary
        let short = info?["CFBundleShortVersionString"] as? String ?? "?"
        let build = info?["CFBundleVersion"] as? String ?? "?"
        return "\(short) (\(build))"
    }

    func signOut() {
        auth.signOut()
    }
}
