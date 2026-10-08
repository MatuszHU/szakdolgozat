import Foundation

@L7
public enum POIKind: Codable, Hashable, Sendable {
    case bar
    case toilet
    case stage
    case entrance
    case emergencyExit
    case cloakroom
    case custom(String)
}

@L7
public struct POI: Identifiable, Codable, Hashable {
    public let id: UUID
    public var name: String
    public var kind: POIKind
    public var outline: [PlanPoint]

    public var area: Double { PlanGeometry.area(of: outline) }
    public var center: PlanPoint { PlanGeometry.centroid(of: outline) }

    public init(id: UUID = UUID(), name: String, kind: POIKind, outline: [PlanPoint]) {
        self.id = id
        self.name = name
        self.kind = kind
        self.outline = outline
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, kind, outline, cell
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        kind = try container.decode(POIKind.self, forKey: .kind)
        outline = try container.decodeIfPresent([PlanPoint].self, forKey: .outline)
            ?? LegacyGridCell.outline(of: container.decodeIfPresent(LegacyGridCell.self, forKey: .cell).map { [$0] } ?? [])
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(kind, forKey: .kind)
        try container.encode(outline, forKey: .outline)
    }
}

@L7
public struct Floor: Identifiable, Codable, Hashable {
    public enum EditError: Error, Equatable {
        case emptyName
        case tooFewPoints
        case noArea
        case wallTooShort
        case outsideSheet
        case duplicateZoneName(String)
        case unknownShape
    }

    public static let gridSpacing = 1.0

    public let id: UUID
    public var name: String
    public var level: Int
    public var width: Double
    public var height: Double
    public private(set) var zones: [Zone] = []
    public private(set) var pointsOfInterest: [POI] = []
    public private(set) var walls: [Wall] = []

    public init(id: UUID = UUID(), name: String, level: Int, width: Double, height: Double) {
        self.id = id
        self.name = name
        self.level = level
        self.width = width
        self.height = height
    }

    private enum CodingKeys: String, CodingKey {
        case id, name, level, width, height, zones, pointsOfInterest, walls
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        level = try container.decode(Int.self, forKey: .level)
        width = try container.decode(Double.self, forKey: .width)
        height = try container.decode(Double.self, forKey: .height)
        zones = try container.decodeIfPresent([Zone].self, forKey: .zones) ?? []
        pointsOfInterest = try container.decodeIfPresent([POI].self, forKey: .pointsOfInterest) ?? []
        walls = try container.decodeIfPresent([Wall].self, forKey: .walls) ?? []
    }

    public func contains(_ point: PlanPoint) -> Bool {
        (0...width).contains(point.x) && (0...height).contains(point.y)
    }

    public func clamped(_ point: PlanPoint) -> PlanPoint {
        PlanPoint(x: min(max(point.x, 0), width), y: min(max(point.y, 0), height))
    }

    public func snapped(_ point: PlanPoint) -> PlanPoint {
        let spacing = Self.gridSpacing
        return clamped(PlanPoint(x: (point.x / spacing).rounded() * spacing, y: (point.y / spacing).rounded() * spacing))
    }

    @discardableResult
    public mutating func addZone(named name: String, outline: [PlanPoint]) throws -> Zone {
        let name = try validName(name)
        try validateArea(outline)
        guard !zones.contains(where: { $0.name == name }) else { throw EditError.duplicateZoneName(name) }
        let zone = Zone(floorID: id, name: name, outline: outline)
        zones.append(zone)
        return zone
    }

    @discardableResult
    public mutating func addPointOfInterest(named name: String, kind: POIKind, outline: [PlanPoint]) throws -> POI {
        let name = try validName(name)
        try validateArea(outline)
        let poi = POI(name: name, kind: kind, outline: outline)
        pointsOfInterest.append(poi)
        return poi
    }

    @discardableResult
    public mutating func addWall(through points: [PlanPoint]) throws -> Wall {
        try validateWall(points)
        let wall = Wall(points: points)
        walls.append(wall)
        return wall
    }

    public func item(at point: PlanPoint, tolerance: Double = 0.3) -> PlanItem? {
        if let wall = walls.last(where: { PlanGeometry.distance(from: point, toLine: $0.points) <= tolerance }) {
            return .wall(wall.id)
        }
        if let poi = pointsOfInterest.last(where: { PlanGeometry.contains(point, in: $0.outline) }) {
            return .pointOfInterest(poi.id)
        }
        return zones.last { PlanGeometry.contains(point, in: $0.outline) }.map { .zone($0.id) }
    }

    public func name(of item: PlanItem) -> String? {
        switch item {
        case .zone(let id): return zones.first { $0.id == id }?.name
        case .pointOfInterest(let id): return pointsOfInterest.first { $0.id == id }?.name
        case .wall(let id): return walls.contains { $0.id == id } ? "Wall" : nil
        }
    }

    public func points(of item: PlanItem) -> [PlanPoint]? {
        switch item {
        case .zone(let id): return zones.first { $0.id == id }?.outline
        case .pointOfInterest(let id): return pointsOfInterest.first { $0.id == id }?.outline
        case .wall(let id): return walls.first { $0.id == id }?.points
        }
    }

    public mutating func move(_ item: PlanItem, dx: Double, dy: Double) throws {
        guard let points = points(of: item) else { throw EditError.unknownShape }
        try replacePoints(of: item, with: points.map { $0.translated(dx: dx, dy: dy) })
    }

    public mutating func movePoint(_ index: Int, of item: PlanItem, to point: PlanPoint) throws {
        guard var points = points(of: item), points.indices.contains(index) else { throw EditError.unknownShape }
        points[index] = point
        try replacePoints(of: item, with: points)
    }

    public mutating func remove(_ item: PlanItem) {
        switch item {
        case .zone(let id): zones.removeAll { $0.id == id }
        case .pointOfInterest(let id): pointsOfInterest.removeAll { $0.id == id }
        case .wall(let id): walls.removeAll { $0.id == id }
        }
    }

    private mutating func replacePoints(of item: PlanItem, with points: [PlanPoint]) throws {
        switch item {
        case .zone(let id):
            try validateArea(points)
            guard let index = zones.firstIndex(where: { $0.id == id }) else { throw EditError.unknownShape }
            zones[index].outline = points
        case .pointOfInterest(let id):
            try validateArea(points)
            guard let index = pointsOfInterest.firstIndex(where: { $0.id == id }) else { throw EditError.unknownShape }
            pointsOfInterest[index].outline = points
        case .wall(let id):
            try validateWall(points)
            guard let index = walls.firstIndex(where: { $0.id == id }) else { throw EditError.unknownShape }
            walls[index].points = points
        }
    }

    private func validName(_ name: String) throws -> String {
        let name = name.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { throw EditError.emptyName }
        return name
    }

    private func validateArea(_ outline: [PlanPoint]) throws {
        guard Set(outline).count >= 3 else { throw EditError.tooFewPoints }
        guard outline.allSatisfy(contains) else { throw EditError.outsideSheet }
        guard PlanGeometry.area(of: outline) > 1e-9 else { throw EditError.noArea }
    }

    private func validateWall(_ points: [PlanPoint]) throws {
        guard Set(points).count >= 2 else { throw EditError.wallTooShort }
        guard points.allSatisfy(contains) else { throw EditError.outsideSheet }
    }
}

@L7 @K16
public struct ZoneCode: Hashable {
    public let floorName: String
    public let zoneName: String
    public let payload: String

    public var label: String { "\(floorName) – \(zoneName)" }
}

@L7
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
    public mutating func addFloor(named name: String, level: Int, width: Double, height: Double) throws -> Floor {
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

    public mutating func editFloor(id: UUID, _ edit: (inout Floor) throws -> Void) throws {
        guard let index = floors.firstIndex(where: { $0.id == id }) else { throw EditError.unknownFloor }
        var floor = floors[index]
        try edit(&floor)
        floors[index] = floor
    }

    @K6 @L4
    public func floor(containingZone zoneID: UUID) -> Floor? {
        floors.first { floor in floor.zones.contains { $0.id == zoneID } }
    }

    public var zoneCodes: [ZoneCode] {
        floors.flatMap { floor in
            floor.zones
                .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
                .map { ZoneCode(floorName: floor.name, zoneName: $0.name, payload: $0.qrPayload) }
        }
    }
}

extension POIKind {
    @M5
    public var isGuestRelevant: Bool {
        if case .custom = self { return false }
        return true
    }
}

extension Floor {
    @M5
    public var forGuests: Floor {
        var floor = self
        floor.zones = []
        floor.pointsOfInterest = pointsOfInterest.filter(\.kind.isGuestRelevant)
        return floor
    }
}

extension Venue {
    @M5
    public var forGuests: Venue {
        var venue = self
        venue.floors = floors.map(\.forGuests)
        return venue
    }

    @M5 @K6
    public var groundFloor: Floor? {
        floors.min { (abs($0.level), $0.level) < (abs($1.level), $1.level) }
    }
}
