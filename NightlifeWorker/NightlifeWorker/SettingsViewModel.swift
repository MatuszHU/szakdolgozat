import Foundation
import Combine
import SharedKit

@K9
enum SettingsItem: CaseIterable, Identifiable {
    case profilePicture
    case language
    case guide
    case about
    case signOut

    var id: Self { self }

    var requiredFeature: WorkerFeature? {
        switch self {
        case .profilePicture: return .profilePicture
        case .guide: return .guide
        case .language, .about, .signOut: return nil
        }
    }
}

@K9 @K14
class SettingsViewModel: ObservableObject {
    let workerName: String?
    private let auth: AuthViewModel
    private let enabledFeatures: Set<WorkerFeature>

    init(auth: AuthViewModel, workerName: String?, enabledFeatures: Set<WorkerFeature>) {
        self.auth = auth
        self.workerName = workerName
        self.enabledFeatures = enabledFeatures
    }

    var items: [SettingsItem] {
        SettingsItem.allCases.filter { item in item.requiredFeature.map(enabledFeatures.contains) ?? true }
    }

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
