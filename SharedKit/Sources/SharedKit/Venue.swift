//
//  Venue.swift
//
//
//  Created by Majoros Máté on 2026. 10. 08..
//


import Foundation

public enum POIKind: Codable, Hashable {
    case bar
    case toilet
    case stage
    case entrance
    case emergencyExit
    case cloakroom
    case custom(String)
}

/// A point of interest placed on one cell of a floor plan.
public struct POI: Identifiable, Codable, Hashable {
    public let id: UUID
    public var name: String
    public var kind: POIKind
    public var cell: GridCell

    public init(id: UUID = UUID(), name: String, kind: POIKind, cell: GridCell) {
        self.id = id
        self.name = name
        self.kind = kind
        self.cell = cell
    }
}

/// One level of a venue: a grid with zones and points of interest (L7).
public struct Floor: Identifiable, Codable, Hashable {
    public enum EditError: Error, Equatable {
        case emptyName
        case noCells
        case outsideGrid
        case overlaps(zoneName: String)
        case duplicateZoneName(String)
        case cellOccupied(by: String)
    }

    public let id: UUID
    public var name: String
    public var level: Int
    public var width: Int
    public var height: Int
    public private(set) var zones: [Zone] = []
    public private(set) var pointsOfInterest: [POI] = []

    public init(id: UUID = UUID(), name: String, level: Int, width: Int, height: Int) {
        self.id = id
        self.name = name
        self.level = level
        self.width = width
        self.height = height
    }

    /// The rectangle of cells between two corners, in any order.
    public static func cells(from first: GridCell, to second: GridCell) -> Set<GridCell> {
        var cells = Set<GridCell>()
        for row in min(first.row, second.row)...max(first.row, second.row) {
            for column in min(first.column, second.column)...max(first.column, second.column) {
                cells.insert(GridCell(row: row, column: column))
            }
        }
        return cells
    }

    public func contains(_ cell: GridCell) -> Bool {
        (0..<width).contains(cell.column) && (0..<height).contains(cell.row)
    }

    public func zone(at cell: GridCell) -> Zone? {
        zones.first { $0.cells.contains(cell) }
    }

    public func pointOfInterest(at cell: GridCell) -> POI? {
        pointsOfInterest.first { $0.cell == cell }
    }

    @discardableResult
    public mutating func addZone(named name: String, cells: Set<GridCell>) throws -> Zone {
        let name = name.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { throw EditError.emptyName }
        guard !cells.isEmpty else { throw EditError.noCells }
        guard cells.allSatisfy(contains) else { throw EditError.outsideGrid }
        guard !zones.contains(where: { $0.name == name }) else { throw EditError.duplicateZoneName(name) }
        if let overlapped = zones.first(where: { !$0.cells.isDisjoint(with: cells) }) {
            throw EditError.overlaps(zoneName: overlapped.name)
        }
        let zone = Zone(floorID: id, name: name, cells: cells)
        zones.append(zone)
        return zone
    }

    public mutating func removeZone(id: UUID) {
        zones.removeAll { $0.id == id }
    }

    @discardableResult
    public mutating func addPointOfInterest(named name: String, kind: POIKind, at cell: GridCell) throws -> POI {
        let name = name.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { throw EditError.emptyName }
        guard contains(cell) else { throw EditError.outsideGrid }
        if let occupant = pointOfInterest(at: cell) {
            throw EditError.cellOccupied(by: occupant.name)
        }
        let poi = POI(name: name, kind: kind, cell: cell)
        pointsOfInterest.append(poi)
        return poi
    }

    public mutating func removePointOfInterest(id: UUID) {
        pointsOfInterest.removeAll { $0.id == id }
    }
}

/// A printable zone QR code with its label (L7, K16).
public struct ZoneCode: Hashable {
    public let floorName: String
    public let zoneName: String
    public let payload: String

    public var label: String { "\(floorName) – \(zoneName)" }
}

/// The venue with its floors, ordered by level (L7).
public struct Venue: Identifiable, Codable, Hashable {
    public enum EditError: Error, Equatable {
        case emptyName
        case invalidSize
        case duplicateLevel(Int)
        case unknownFloor
    }

    public let id: UUID
    public var name: String
    public private(set) var floors: [Floor] = []

    public init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }

    @discardableResult
    public mutating func addFloor(named name: String, level: Int, width: Int, height: Int) throws -> Floor {
        let name = name.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { throw EditError.emptyName }
        guard width > 0, height > 0 else { throw EditError.invalidSize }
        guard !floors.contains(where: { $0.level == level }) else { throw EditError.duplicateLevel(level) }
        let floor = Floor(name: name, level: level, width: width, height: height)
        floors.append(floor)
        floors.sort { $0.level < $1.level }
        return floor
    }

    public mutating func removeFloor(id: UUID) {
        floors.removeAll { $0.id == id }
    }

    /// Applies an edit to one floor; the floor is unchanged if the edit throws.
    public mutating func editFloor(id: UUID, _ edit: (inout Floor) throws -> Void) throws {
        guard let index = floors.firstIndex(where: { $0.id == id }) else { throw EditError.unknownFloor }
        var floor = floors[index]
        try edit(&floor)
        floors[index] = floor
    }

    /// All zone codes, by floor level and zone name.
    public var zoneCodes: [ZoneCode] {
        floors.flatMap { floor in
            floor.zones
                .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
                .map { ZoneCode(floorName: floor.name, zoneName: $0.name, payload: $0.qrPayload) }
        }
    }
}
