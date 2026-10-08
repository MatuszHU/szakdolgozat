import Foundation
import Combine
import SharedKit

@M5
class GuestMapViewModel: ObservableObject {
    let floors: [Floor]
    @Published private(set) var selectedFloorID: UUID?

    init(venue: Venue) {
        let guestVenue = venue.forGuests
        floors = guestVenue.floors
        selectedFloorID = guestVenue.groundFloor?.id
    }

    var hasMap: Bool { !floors.isEmpty }

    var selectedFloor: Floor? {
        floors.first { $0.id == selectedFloorID }
    }

    var places: [POI] {
        (selectedFloor?.pointsOfInterest ?? [])
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    func selectFloor(id: UUID) {
        selectedFloorID = id
    }
}
