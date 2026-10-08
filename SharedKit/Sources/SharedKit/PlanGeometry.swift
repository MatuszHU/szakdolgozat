import Foundation

@L7
public struct PlanPoint: Codable, Hashable, Sendable {
    public var x: Double
    public var y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    public func translated(dx: Double, dy: Double) -> PlanPoint {
        PlanPoint(x: x + dx, y: y + dy)
    }

    public func distance(to other: PlanPoint) -> Double {
        hypot(other.x - x, other.y - y)
    }
}

@L7
public enum PlanItem: Hashable, Sendable {
    case zone(UUID)
    case pointOfInterest(UUID)
    case wall(UUID)
}

@L7
public struct Wall: Identifiable, Codable, Hashable {
    public let id: UUID
    public var points: [PlanPoint]

    public init(id: UUID = UUID(), points: [PlanPoint]) {
        self.id = id
        self.points = points
    }
}

@L7
public enum PlanGeometry {
    public static func area(of polygon: [PlanPoint]) -> Double {
        abs(signedArea(of: polygon))
    }

    public static func centroid(of polygon: [PlanPoint]) -> PlanPoint {
        let area = signedArea(of: polygon)
        guard abs(area) > 1e-12 else {
            let count = Double(max(polygon.count, 1))
            return PlanPoint(x: polygon.map(\.x).reduce(0, +) / count, y: polygon.map(\.y).reduce(0, +) / count)
        }
        var x = 0.0, y = 0.0
        for (a, b) in edges(of: polygon) {
            let cross = a.x * b.y - b.x * a.y
            x += (a.x + b.x) * cross
            y += (a.y + b.y) * cross
        }
        return PlanPoint(x: x / (6 * area), y: y / (6 * area))
    }

    public static func contains(_ point: PlanPoint, in polygon: [PlanPoint]) -> Bool {
        guard polygon.count >= 3 else { return false }
        var inside = false
        for (a, b) in edges(of: polygon) where (a.y > point.y) != (b.y > point.y) {
            let crossingX = a.x + (point.y - a.y) / (b.y - a.y) * (b.x - a.x)
            if point.x < crossingX { inside.toggle() }
        }
        return inside
    }

    public static func distance(from point: PlanPoint, toLine line: [PlanPoint]) -> Double {
        guard let first = line.first else { return .infinity }
        guard line.count > 1 else { return point.distance(to: first) }
        return zip(line, line.dropFirst()).map { distance(from: point, toSegment: $0, $1) }.min() ?? .infinity
    }

    private static func distance(from point: PlanPoint, toSegment a: PlanPoint, _ b: PlanPoint) -> Double {
        let dx = b.x - a.x, dy = b.y - a.y
        let lengthSquared = dx * dx + dy * dy
        guard lengthSquared > 0 else { return point.distance(to: a) }
        let t = min(max(((point.x - a.x) * dx + (point.y - a.y) * dy) / lengthSquared, 0), 1)
        return point.distance(to: PlanPoint(x: a.x + t * dx, y: a.y + t * dy))
    }

    private static func signedArea(of polygon: [PlanPoint]) -> Double {
        guard polygon.count >= 3 else { return 0 }
        return edges(of: polygon).reduce(0) { $0 + $1.0.x * $1.1.y - $1.1.x * $1.0.y } / 2
    }

    private static func edges(of polygon: [PlanPoint]) -> [(PlanPoint, PlanPoint)] {
        Array(zip(polygon, polygon.dropFirst() + polygon.prefix(1)))
    }
}

struct LegacyGridCell: Decodable {
    let row: Int
    let column: Int

    static func outline(of cells: [LegacyGridCell]) -> [PlanPoint] {
        guard let minX = cells.map(\.column).min(), let maxX = cells.map(\.column).max(),
              let minY = cells.map(\.row).min(), let maxY = cells.map(\.row).max() else { return [] }
        let left = Double(minX), right = Double(maxX + 1), top = Double(minY), bottom = Double(maxY + 1)
        return [PlanPoint(x: left, y: top), PlanPoint(x: right, y: top),
                PlanPoint(x: right, y: bottom), PlanPoint(x: left, y: bottom)]
    }
}
