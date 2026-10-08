import Foundation
import SharedKit

@K8
protocol PanicAlertSending {
    func send(_ alert: PanicAlert, message: String, to recipientIDs: [UUID])
}

@K8
class PanicViewModel {
    private(set) var activeAlert: PanicAlert?
    private let worker: WorkerUser
    private let colleagues: [WorkerUser]
    private let zones: [Zone]
    private let sender: PanicAlertSending
    private let notifiedRoles: Set<WorkerRole>

    init(worker: WorkerUser, colleagues: [WorkerUser], zones: [Zone],
         sender: PanicAlertSending, notifiedRoles: Set<WorkerRole> = [.security]) {
        self.worker = worker
        self.colleagues = colleagues
        self.zones = zones
        self.sender = sender
        self.notifiedRoles = notifiedRoles
    }

    func activate(currentZoneID: UUID?, at date: Date = Date()) {
        let alert = PanicAlert(workerID: worker.id, timestamp: date, zoneID: currentZoneID)
        let zone = zones.first { $0.id == currentZoneID }
        sender.send(alert,
                    message: PanicAlert.message(for: worker, zone: zone),
                    to: PanicAlert.recipients(for: worker, among: colleagues, notifying: notifiedRoles))
        activeAlert = alert
    }
}

@K8
class PanicInboxViewModel {
    let user: WorkerUser
    private(set) var alerts: [PanicAlert] = []

    init(user: WorkerUser) {
        self.user = user
    }

    func receive(_ alert: PanicAlert) {
        if let index = alerts.firstIndex(where: { $0.id == alert.id }) {
            alerts[index] = alert
        } else {
            alerts.append(alert)
        }
    }

    func acknowledge(alertID: UUID, at date: Date = Date()) -> PanicAlert? {
        guard let index = alerts.firstIndex(where: { $0.id == alertID }),
              alerts[index].acknowledge(by: user.id, at: date) else { return nil }
        return alerts[index]
    }
}
