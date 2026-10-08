//
//  FloorPlanView.swift
//
//
//  Created by Majoros Máté on 2026. 10. 08..
//


import SwiftUI

extension POIKind {
    /// SF Symbol shown on the floor plan.
    public var symbolName: String {
        switch self {
        case .bar: return "wineglass"
        case .toilet: return "toilet"
        case .stage: return "music.mic"
        case .entrance: return "door.left.hand.open"
        case .emergencyExit: return "figure.walk.departure"
        case .cloakroom: return "hanger"
        case .custom: return "mappin"
        }
    }
}

/// Draws one floor: grid, zones, points of interest, an optional selection and per-zone badges.
/// Used by the designer (L7, editable through gestures added by the caller) and the maps (K6, M5).
@available(iOS 17.0, macOS 14.0, *)
public struct FloorPlanView: View {
    public static let palette: [Color] = [.orange, .blue, .green, .purple, .pink, .teal, .yellow, .indigo]

    public let floor: Floor
    public var selection: Set<GridCell>
    public var highlightedZoneID: UUID?
    public var zoneBadges: [UUID: [String]]
    public var cellSize: CGFloat

    public init(floor: Floor,
                selection: Set<GridCell> = [],
                highlightedZoneID: UUID? = nil,
                zoneBadges: [UUID: [String]] = [:],
                cellSize: CGFloat = 32) {
        self.floor = floor
        self.selection = selection
        self.highlightedZoneID = highlightedZoneID
        self.zoneBadges = zoneBadges
        self.cellSize = cellSize
    }

    /// The grid cell under a point of the view (may be outside the floor).
    nonisolated public static func cell(at point: CGPoint, cellSize: CGFloat) -> GridCell {
        GridCell(row: Int((point.y / cellSize).rounded(.down)),
                 column: Int((point.x / cellSize).rounded(.down)))
    }

    public var body: some View {
        Canvas { context, _ in
            for row in 0..<floor.height {
                for column in 0..<floor.width {
                    let cell = GridCell(row: row, column: column)
                    context.fill(Path(rect(for: cell).insetBy(dx: 1, dy: 1)), with: .color(fill(for: cell)))
                }
            }
            for zone in floor.zones {
                guard let corner = zone.cells.min(by: { ($0.row, $0.column) < ($1.row, $1.column) }) else { continue }
                var label = zone.name
                if let badges = zoneBadges[zone.id], !badges.isEmpty {
                    label += " · " + badges.joined(separator: ", ")
                }
                context.draw(Text(label).font(.caption2.bold()),
                             at: CGPoint(x: rect(for: corner).minX + 4, y: rect(for: corner).minY + 4),
                             anchor: .topLeading)
            }
            for poi in floor.pointsOfInterest {
                let frame = rect(for: poi.cell)
                context.draw(Image(systemName: poi.kind.symbolName), at: CGPoint(x: frame.midX, y: frame.midY))
            }
        }
        .frame(width: CGFloat(floor.width) * cellSize, height: CGFloat(floor.height) * cellSize)
        .accessibilityElement()
        .accessibilityLabel(Text(accessibilitySummary))
    }

    private func rect(for cell: GridCell) -> CGRect {
        CGRect(x: CGFloat(cell.column) * cellSize, y: CGFloat(cell.row) * cellSize, width: cellSize, height: cellSize)
    }

    private func fill(for cell: GridCell) -> Color {
        if selection.contains(cell) { return Color.accentColor.opacity(0.5) }
        guard let zone = floor.zone(at: cell),
              let index = floor.zones.firstIndex(where: { $0.id == zone.id }) else { return Color.gray.opacity(0.12) }
        let color = Self.palette[index % Self.palette.count]
        return color.opacity(zone.id == highlightedZoneID ? 0.85 : 0.45)
    }

    private var accessibilitySummary: String {
        let zones = floor.zones.map { zone -> String in
            let people = zoneBadges[zone.id] ?? []
            return people.isEmpty ? zone.name : "\(zone.name): \(people.joined(separator: ", "))"
        }
        return ([floor.name] + zones + floor.pointsOfInterest.map(\.name)).joined(separator: "; ")
    }
}
