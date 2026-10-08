import Foundation
import Combine
import SharedKit

@L8
class RequestLogViewModel: ObservableObject {
    @Published var showsOnlyOpen = false
    private let log: RequestLog

    init(alerts: [PanicAlert], inventory: Inventory, staff: [WorkerUser]) {
        log = RequestLog(alerts: alerts, inventory: inventory, staff: staff)
    }

    var entries: [RequestLog.Entry] {
        showsOnlyOpen ? log.openEntries : log.entries
    }

    func count(of category: RequestLog.Category) -> Int {
        log.count(of: category, openOnly: showsOnlyOpen)
    }

    func entries(in category: RequestLog.Category) -> [RequestLog.Entry] {
        entries.filter { $0.category == category }
    }
}
