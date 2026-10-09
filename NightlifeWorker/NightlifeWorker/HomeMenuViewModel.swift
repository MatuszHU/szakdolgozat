import Foundation
import Combine
import SharedKit

@K4 @L6
enum HomeItem: CaseIterable, Identifiable {
    case schedule
    case notifications
    case codeReader
    case map
    case supplyRequest
    case summary

    var id: Self { self }

    var requiredFeature: WorkerFeature? {
        switch self {
        case .supplyRequest: return .supplyRequests
        case .summary: return .statistics
        default: return nil
        }
    }
}

@K4 @L6
class HomeMenuViewModel: ObservableObject {
    @Published var enabledFeatures: Set<WorkerFeature>

    init(enabledFeatures: Set<WorkerFeature> = Set(WorkerFeature.allCases)) {
        self.enabledFeatures = enabledFeatures
    }

    var items: [HomeItem] {
        HomeItem.allCases.filter { item in item.requiredFeature.map(enabledFeatures.contains) ?? true }
    }

    func isEnabled(_ feature: WorkerFeature) -> Bool {
        enabledFeatures.contains(feature)
    }

    @K15
    var showsGuide: Bool { isEnabled(.guide) }
}
