import XCTest
import CucumberSwift
import CucumberSwiftExpressions
import SharedKit
@testable import NightlifeManager

@L7
final class InMemoryVenueStore: VenueStoring {
    private(set) var saved: Venue?

    func load() -> Venue? { saved }

    func save(_ venue: Venue) throws {
        saved = venue
    }
}

@L7
func planPoints(_ text: String) -> [PlanPoint] {
    text.split(separator: " ").compactMap { pair in
        let values = pair.split(separator: ",").compactMap { Double($0) }
        return values.count == 2 ? PlanPoint(x: values[0], y: values[1]) : nil
    }
}

@L7
func poiKind(_ text: String) -> POIKind {
    switch text {
    case "bar": return .bar
    case "toilet": return .toilet
    case "stage": return .stage
    case "entrance": return .entrance
    case "emergency exit": return .emergencyExit
    case "cloakroom": return .cloakroom
    default: return .custom(text)
    }
}

extension Cucumber {

    @L7
    func setupVenueDesignerSteps() {
        var viewModel: VenueDesignerViewModel!
        var codeSheet: [ZoneCode] = []

        func floor(named name: String) -> Floor? {
            viewModel.venue.floors.first { $0.name == name }
        }

        func zone(named name: String) -> Zone? {
            viewModel.floor?.zones.first { $0.name == name }
        }

        func tool(_ name: String) -> VenueDesignerViewModel.Tool {
            switch name {
            case "polygon": return .polygon
            case "wall": return .wall
            default: return .select
            }
        }

        func draw(_ points: String, as kind: VenueDesignerViewModel.ShapeKind, named name: String) {
            viewModel.tool = .polygon
            let outline = planPoints(points)
            for point in outline + outline.prefix(1) { viewModel.click(at: point) }
            viewModel.saveShape(named: name, as: kind)
        }

        Given("a venue {string} with the floor {string} at level {int} of {int} by {int} metres") { match, _ in
            let names = try match.allParameters(\.string)
            let numbers = try match.allParameters(\.int)
            viewModel = VenueDesignerViewModel(venue: Venue(name: names[0]), store: InMemoryVenueStore())
            codeSheet = []
            viewModel.addFloor(named: names[1], level: numbers[0], width: Double(numbers[1]), height: Double(numbers[2]))
            XCTAssertNil(viewModel.errorMessage)
        }

        Given("the administrator uses the {string} tool") { match, _ in
            viewModel.tool = tool(try match.first(\.string))
        }

        Given("snapping to the grid is turned off") { _, _ in
            viewModel.snapsToGrid = false
        }

        Given("the administrator drew the zone {string} through {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            draw(texts[1], as: .zone, named: texts[0])
            XCTAssertNil(viewModel.errorMessage)
        }

        Given("the administrator drew a {string} named {string} through {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            draw(texts[2], as: .pointOfInterest(poiKind(texts[0])), named: texts[1])
            XCTAssertNil(viewModel.errorMessage)
        }

        Given("the administrator selected {string}") { match, _ in
            let name = try match.first(\.string)
            let floor = try XCTUnwrap(viewModel.floor)
            let item = floor.zones.first { $0.name == name }.map { PlanItem.zone($0.id) }
                ?? floor.pointsOfInterest.first { $0.name == name }.map { PlanItem.pointOfInterest($0.id) }
            viewModel.select(try XCTUnwrap(item))
        }

        When("the administrator clicks {string}") { match, _ in
            for point in planPoints(try match.first(\.string)) { viewModel.click(at: point) }
        }

        When("the administrator saves the shape as the zone {string}") { match, _ in
            viewModel.saveShape(named: try match.first(\.string), as: .zone)
        }

        When("the administrator saves the shape as a {string} named {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            viewModel.saveShape(named: texts[1], as: .pointOfInterest(poiKind(texts[0])))
        }

        When("the administrator draws the zone {string} through {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            draw(texts[1], as: .zone, named: texts[0])
        }

        When("the administrator finishes the drawing") { _, _ in
            viewModel.finishDrawing()
        }

        When("the administrator cancels the drawing") { _, _ in
            viewModel.cancelDrawing()
        }

        When("the administrator moves the selection by {string}") { match, _ in
            let offset = try XCTUnwrap(planPoints(try match.first(\.string)).first)
            viewModel.moveSelection(dx: offset.x, dy: offset.y)
        }

        When("the administrator drags the point {string} to {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            let from = try XCTUnwrap(planPoints(texts[0]).first)
            let index = try XCTUnwrap(viewModel.pointIndex(near: from))
            viewModel.dragPoint(index, to: try XCTUnwrap(planPoints(texts[1]).first))
        }

        When("the administrator deletes the selection") { _, _ in
            viewModel.deleteSelection()
        }

        When("the administrator adds the floor {string} at level {int} of {int} by {int} metres") { match, _ in
            let numbers = try match.allParameters(\.int)
            viewModel.addFloor(named: try match.first(\.string), level: numbers[0],
                               width: Double(numbers[1]), height: Double(numbers[2]))
        }

        When("the administrator prints the zone codes") { _, _ in
            codeSheet = viewModel.zoneCodes
        }

        Then("the zone {string} has the corners {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            XCTAssertEqual(zone(named: texts[0])?.outline, planPoints(texts[1]))
        }

        Then("the zone {string} has an area of {int} square metres") { match, _ in
            XCTAssertEqual(zone(named: try match.first(\.string))?.area, Double(try match.first(\.int)))
        }

        Then("the point of interest {string} is a {string} of {int} square metres centred at {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            let poi = try XCTUnwrap(viewModel.floor?.pointsOfInterest.first { $0.name == texts[0] })
            XCTAssertEqual(poi.kind, poiKind(texts[1]))
            XCTAssertEqual(poi.area, Double(try match.first(\.int)))
            XCTAssertEqual(poi.center, planPoints(texts[2]).first)
        }

        Then("the floor {string} has the zones {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            XCTAssertEqual(floor(named: texts[0])?.zones.map(\.name).joined(separator: ", "), texts[1])
        }

        Then("the floor {string} has a wall through {string}") { match, _ in
            let texts = try match.allParameters(\.string)
            XCTAssertEqual(floor(named: texts[0])?.walls.map(\.points), [planPoints(texts[1])])
        }

        Then("the floor {string} has no shapes") { match, _ in
            let floor = try XCTUnwrap(floor(named: try match.first(\.string)))
            XCTAssertTrue(floor.zones.isEmpty && floor.pointsOfInterest.isEmpty && floor.walls.isEmpty)
        }

        Then("nothing is being drawn") { _, _ in
            XCTAssertTrue(viewModel.draft.isEmpty)
            XCTAssertNil(viewModel.closedOutline)
        }

        Then("the selection is {string}") { match, _ in
            let selection = try XCTUnwrap(viewModel.selection)
            XCTAssertEqual(viewModel.floor?.name(of: selection), try match.first(\.string))
        }

        Then("the designer shows {string}") { match, _ in
            XCTAssertEqual(viewModel.errorMessage, try match.first(\.string))
        }

        Then("the designer shows no error") { _, _ in
            XCTAssertNil(viewModel.errorMessage)
        }

        Then("the venue's floors are {string}") { match, _ in
            XCTAssertEqual(viewModel.venue.floors.map(\.name).joined(separator: ", "), try match.first(\.string))
        }

        Then("the code sheet lists {string} and {string}") { match, _ in
            XCTAssertEqual(codeSheet.map(\.label), try match.allParameters(\.string))
        }

        Then("every code on the sheet opens its own zone") { _, _ in
            let zones = viewModel.venue.floors.flatMap(\.zones)
            for code in codeSheet {
                let zoneID = Zone.zoneID(fromQRPayload: code.payload)
                XCTAssertEqual(zones.first { $0.id == zoneID }?.name, code.zoneName)
            }
            XCTAssertEqual(Set(codeSheet.map(\.payload)).count, codeSheet.count)
        }
    }
}
