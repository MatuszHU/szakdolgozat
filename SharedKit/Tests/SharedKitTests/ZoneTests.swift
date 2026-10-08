import Foundation
import Testing
@testable import SharedKit

@Suite("Zone")
@K16
struct ZoneTests {

    @Test func qrPayloadContainsZoneID() {
        let zone = Zone(name: "Bar")
        #expect(zone.qrPayload == "nightlife://zone/\(zone.id.uuidString)")
    }

    @Test func parsesOwnQRPayload() {
        let zone = Zone(name: "Bar")
        #expect(Zone.zoneID(fromQRPayload: zone.qrPayload) == zone.id)
    }

    @Test(arguments: [
        "https://example.com/not-a-zone",
        "nightlife://ticket/\(UUID().uuidString)",
        "nightlife://zone/not-a-uuid",
        "",
    ])
    func rejectsForeignPayloads(_ payload: String) {
        #expect(Zone.zoneID(fromQRPayload: payload) == nil)
    }
}

@Suite("WorkerPosition")
@K16 @N4
struct WorkerPositionTests {

    private let bar = Zone(name: "Bar")
    private let entrance = Zone(name: "Entrance")
    private var known: Set<UUID> { [bar.id, entrance.id] }

    @Test func checkInOnShiftSetsZoneAndRecordsIt() throws {
        var position = WorkerPosition(workerID: UUID(), isOnShift: true)
        try position.checkIn(scanning: bar.qrPayload, knownZoneIDs: known)
        #expect(position.currentZoneID == bar.id)
        #expect(position.checkIns.map(\.zoneID) == [bar.id])
    }

    @Test func checkInToAnotherZoneMovesWorker() throws {
        var position = WorkerPosition(workerID: UUID(), isOnShift: true)
        try position.checkIn(scanning: bar.qrPayload, knownZoneIDs: known)
        try position.checkIn(scanning: entrance.qrPayload, knownZoneIDs: known)
        #expect(position.currentZoneID == entrance.id)
        #expect(position.checkIns.count == 2)
    }

    @Test func foreignCodeIsRejectedAndKeepsPosition() throws {
        var position = WorkerPosition(workerID: UUID(), isOnShift: true)
        try position.checkIn(scanning: bar.qrPayload, knownZoneIDs: known)
        #expect(throws: WorkerPosition.CheckInError.invalidCode) {
            try position.checkIn(scanning: "https://example.com", knownZoneIDs: known)
        }
        #expect(position.currentZoneID == bar.id)
    }

    @Test func unknownZoneIsRejected() {
        var position = WorkerPosition(workerID: UUID(), isOnShift: true)
        let otherVenueZone = Zone(name: "Elsewhere")
        #expect(throws: WorkerPosition.CheckInError.invalidCode) {
            try position.checkIn(scanning: otherVenueZone.qrPayload, knownZoneIDs: known)
        }
        #expect(position.currentZoneID == nil)
    }

    @Test func checkInOutsideShiftIsRejected() {
        var position = WorkerPosition(workerID: UUID(), isOnShift: false)
        #expect(throws: WorkerPosition.CheckInError.notOnShift) {
            try position.checkIn(scanning: bar.qrPayload, knownZoneIDs: known)
        }
        #expect(position.currentZoneID == nil)
        #expect(position.checkIns.isEmpty)
    }

    @Test func endingShiftClearsPosition() throws {
        var position = WorkerPosition(workerID: UUID(), isOnShift: true)
        try position.checkIn(scanning: bar.qrPayload, knownZoneIDs: known)
        position.endShift()
        #expect(position.currentZoneID == nil)
        #expect(!position.isOnShift)
    }
}
