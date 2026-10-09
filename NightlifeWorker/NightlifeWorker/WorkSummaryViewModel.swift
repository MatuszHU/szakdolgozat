import Foundation
import Combine
import SharedKit

@K12
class WorkSummaryViewModel: ObservableObject {
    @Published private(set) var summary: WorkerSummary
    private let workerID: UUID
    private let shifts: [Shift]
    private let payPeriod: PayPeriod
    private let now: () -> Date

    init(workerID: UUID, shifts: [Shift], payPeriod: PayPeriod, now: @escaping () -> Date = Date.init) {
        self.workerID = workerID
        self.shifts = shifts
        self.payPeriod = payPeriod
        self.now = now
        summary = WorkerSummary(workerID: workerID, shifts: shifts, payPeriod: payPeriod, at: now())
    }

    func refresh() {
        summary = WorkerSummary(workerID: workerID, shifts: shifts, payPeriod: payPeriod, at: now())
    }
}
