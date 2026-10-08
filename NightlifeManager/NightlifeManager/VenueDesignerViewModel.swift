import Foundation
import Combine
import SharedKit

@L7
protocol VenueStoring {
    func load() -> Venue?
    func save(_ venue: Venue) throws
}

@L7
class VenueDesignerViewModel: ObservableObject {
    enum Tool: CaseIterable {
        case select
        case polygon
        case wall
    }

    enum ShapeKind: Hashable {
        case zone
        case pointOfInterest(POIKind)
    }

    static let closeDistance = 0.5
    static let handleDistance = 0.5

    @Published private(set) var venue: Venue
    @Published private(set) var errorMessage: String?
    @Published private(set) var floorID: UUID?
    @Published private(set) var draft: [PlanPoint] = []
    @Published private(set) var closedOutline: [PlanPoint]?
    @Published private(set) var selection: PlanItem?
    @Published var snapsToGrid = true
    @Published var tool = Tool.select {
        didSet {
            draft = []
            closedOutline = nil
            if tool != .select { selection = nil }
        }
    }
    private let store: VenueStoring

    init(venue: Venue, store: VenueStoring) {
        self.venue = venue
        self.store = store
        floorID = venue.floors.first?.id
    }

    var floor: Floor? { venue.floors.first { $0.id == floorID } ?? venue.floors.first }
    var zoneCodes: [ZoneCode] { venue.zoneCodes }

    func addFloor(named name: String, level: Int, width: Double, height: Double) {
        apply { try $0.addFloor(named: name, level: level, width: width, height: height) }
        if errorMessage == nil {
            selectFloor(venue.floors.first { $0.level == level }?.id)
        }
    }

    func selectFloor(_ id: UUID?) {
        floorID = id
        selection = nil
        cancelDrawing()
    }

    func position(of point: PlanPoint) -> PlanPoint? {
        floor.map { snapsToGrid ? $0.snapped(point) : $0.clamped(point) }
    }

    func click(at point: PlanPoint) {
        guard let floor, let position = position(of: point) else { return }
        switch tool {
        case .select:
            selection = floor.item(at: point)
        case .polygon:
            if draft.count >= 3, position.distance(to: draft[0]) <= Self.closeDistance {
                closeShape()
            } else if draft.last != position {
                draft.append(position)
            }
        case .wall:
            if draft.last != position { draft.append(position) }
        }
    }

    func finishDrawing() {
        switch tool {
        case .select:
            break
        case .polygon:
            closeShape()
        case .wall:
            let points = draft
            editFloor { try $0.addWall(through: points) }
            if errorMessage == nil { draft = [] }
        }
    }

    func undoLastPoint() {
        _ = draft.popLast()
    }

    func cancelDrawing() {
        draft = []
        closedOutline = nil
    }

    func saveShape(named name: String, as kind: ShapeKind) {
        guard let outline = closedOutline else { return }
        editFloor { floor in
            switch kind {
            case .zone: try floor.addZone(named: name, outline: outline)
            case .pointOfInterest(let poiKind): try floor.addPointOfInterest(named: name, kind: poiKind, outline: outline)
            }
        }
        if errorMessage == nil { closedOutline = nil }
    }

    func select(_ item: PlanItem?) {
        tool = .select
        selection = item
    }

    func offset(_ distance: Double) -> Double {
        snapsToGrid ? (distance / Floor.gridSpacing).rounded() * Floor.gridSpacing : distance
    }

    func moveSelection(dx: Double, dy: Double) {
        guard let selection else { return }
        editFloor { try $0.move(selection, dx: offset(dx), dy: offset(dy)) }
    }

    func pointIndex(near point: PlanPoint) -> Int? {
        guard let selection, let points = floor?.points(of: selection) else { return nil }
        guard let index = points.indices.min(by: { points[$0].distance(to: point) < points[$1].distance(to: point) }),
              points[index].distance(to: point) <= Self.handleDistance else { return nil }
        return index
    }

    func dragPoint(_ index: Int, to point: PlanPoint) {
        guard let selection, let position = position(of: point) else { return }
        editFloor { try $0.movePoint(index, of: selection, to: position) }
    }

    func deleteSelection() {
        guard let selection else { return }
        editFloor { $0.remove(selection) }
        self.selection = nil
    }

    private func closeShape() {
        guard Set(draft).count >= 3 else {
            errorMessage = Self.message(for: Floor.EditError.tooFewPoints)
            return
        }
        closedOutline = draft
        draft = []
        errorMessage = nil
    }

    private func editFloor(_ edit: (inout Floor) throws -> Void) {
        guard let id = floor?.id else { return }
        apply { try $0.editFloor(id: id, edit) }
    }

    private func apply(_ edit: (inout Venue) throws -> Void) {
        var edited = venue
        do {
            try edit(&edited)
            venue = edited
            errorMessage = nil
            try store.save(edited)
        } catch let error as Floor.EditError {
            errorMessage = Self.message(for: error)
        } catch let error as Venue.EditError {
            errorMessage = Self.message(for: error)
        } catch {
            errorMessage = "The venue could not be saved"
        }
    }

    private static func message(for error: Floor.EditError) -> String {
        switch error {
        case .emptyName: return "A name is required"
        case .tooFewPoints: return "A shape needs at least three points"
        case .noArea: return "The shape has no area"
        case .wallTooShort: return "A wall needs at least two points"
        case .outsideSheet: return "The shape is outside the sheet"
        case .duplicateZoneName(let name): return "A zone named \(name) already exists"
        case .unknownShape: return "The shape no longer exists"
        }
    }

    private static func message(for error: Venue.EditError) -> String {
        switch error {
        case .emptyName: return "A name is required"
        case .invalidSize: return "The sheet size must be positive"
        case .duplicateLevel(let level): return "Level \(level) already exists"
        case .unknownFloor: return "The floor no longer exists"
        }
    }
}
