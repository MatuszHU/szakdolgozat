import SwiftUI

extension POIKind {
    @L7 @K6
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

@available(iOS 17.0, macOS 14.0, *)
@L7 @K6 @L4 @M5
public struct FloorPlanView: View {
    public static let palette: [Color] = [.orange, .blue, .green, .purple, .pink, .teal, .yellow, .indigo]

    public let floor: Floor
    public var scale: CGFloat
    public var highlightedZoneID: UUID?
    public var zoneBadges: [UUID: [String]]
    public var selection: PlanItem?
    public var draft: [PlanPoint]
    public var draftIsWall: Bool
    public var showsGrid: Bool

    public init(floor: Floor,
                scale: CGFloat = 24,
                highlightedZoneID: UUID? = nil,
                zoneBadges: [UUID: [String]] = [:],
                selection: PlanItem? = nil,
                draft: [PlanPoint] = [],
                draftIsWall: Bool = false,
                showsGrid: Bool = true) {
        self.floor = floor
        self.scale = scale
        self.highlightedZoneID = highlightedZoneID
        self.zoneBadges = zoneBadges
        self.selection = selection
        self.draft = draft
        self.draftIsWall = draftIsWall
        self.showsGrid = showsGrid
    }

    nonisolated public static func planPoint(at location: CGPoint, scale: CGFloat) -> PlanPoint {
        PlanPoint(x: Double(location.x / scale), y: Double(location.y / scale))
    }

    nonisolated public static func viewPoint(for point: PlanPoint, scale: CGFloat) -> CGPoint {
        CGPoint(x: CGFloat(point.x) * scale, y: CGFloat(point.y) * scale)
    }

    nonisolated public static func fittingScale(for floor: Floor, in size: CGSize) -> CGFloat {
        min(size.width / CGFloat(floor.width), size.height / CGFloat(floor.height))
    }

    public var body: some View {
        Canvas { context, _ in
            let sheet = CGRect(x: 0, y: 0, width: CGFloat(floor.width) * scale, height: CGFloat(floor.height) * scale)
            context.fill(Path(roundedRect: sheet, cornerRadius: 6), with: .color(.gray.opacity(0.08)))
            if showsGrid { drawDots(in: &context) }
            for (index, zone) in floor.zones.enumerated() {
                let color = Self.palette[index % Self.palette.count]
                let path = polygon(zone.outline)
                context.fill(path, with: .color(color.opacity(zone.id == highlightedZoneID ? 0.75 : 0.3)))
                context.stroke(path, with: .color(color), lineWidth: 1.5)
            }
            for poi in floor.pointsOfInterest {
                let path = polygon(poi.outline)
                context.fill(path, with: .color(.primary.opacity(0.12)))
                context.stroke(path, with: .color(.primary.opacity(0.55)), lineWidth: 1)
            }
            for wall in floor.walls {
                context.stroke(line(wall.points), with: .color(.primary.opacity(0.8)),
                               style: StrokeStyle(lineWidth: max(3, scale * 0.2), lineCap: .round, lineJoin: .round))
            }
            for zone in floor.zones {
                var label = zone.name
                if let badges = zoneBadges[zone.id], !badges.isEmpty {
                    label += " · " + badges.joined(separator: ", ")
                }
                let corner = CGPoint(x: CGFloat(zone.outline.map(\.x).min() ?? 0) * scale + 4,
                                     y: CGFloat(zone.outline.map(\.y).min() ?? 0) * scale + 4)
                context.draw(Text(label).font(.caption2.bold()), at: corner, anchor: .topLeading)
            }
            for poi in floor.pointsOfInterest {
                let center = Self.viewPoint(for: poi.center, scale: scale)
                context.draw(Image(systemName: poi.kind.symbolName), at: center, anchor: .bottom)
                context.draw(Text(poi.name).font(.caption2), at: CGPoint(x: center.x, y: center.y + 2), anchor: .top)
            }
            if let selection, let points = floor.points(of: selection) {
                let path = if case .wall = selection { line(points) } else { polygon(points) }
                context.stroke(path, with: .color(.accentColor), style: StrokeStyle(lineWidth: 2, dash: [6, 3]))
                for point in points { drawHandle(at: point, in: &context) }
            }
            if !draft.isEmpty {
                context.stroke(line(draft), with: .color(.accentColor), style: StrokeStyle(lineWidth: 2, dash: [4, 3]))
                for (index, point) in draft.enumerated() {
                    let radius: CGFloat = index == 0 && !draftIsWall ? 6 : 3.5
                    let center = Self.viewPoint(for: point, scale: scale)
                    context.fill(Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius,
                                                        width: radius * 2, height: radius * 2)),
                                 with: .color(.accentColor))
                }
            }
        }
        .frame(width: CGFloat(floor.width) * scale, height: CGFloat(floor.height) * scale)
        .accessibilityElement()
        .accessibilityLabel(Text(accessibilitySummary))
    }

    private func drawDots(in context: inout GraphicsContext) {
        let spacing = Floor.gridSpacing
        let radius: CGFloat = 1.3
        var dots = Path()
        for x in stride(from: 0.0, through: floor.width, by: spacing) {
            for y in stride(from: 0.0, through: floor.height, by: spacing) {
                let center = Self.viewPoint(for: PlanPoint(x: x, y: y), scale: scale)
                dots.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
            }
        }
        context.fill(dots, with: .color(.gray.opacity(0.45)))
    }

    private func drawHandle(at point: PlanPoint, in context: inout GraphicsContext) {
        let center = Self.viewPoint(for: point, scale: scale)
        let handle = CGRect(x: center.x - 4, y: center.y - 4, width: 8, height: 8)
        context.fill(Path(handle), with: .color(.white))
        context.stroke(Path(handle), with: .color(.accentColor), lineWidth: 1.5)
    }

    private func line(_ points: [PlanPoint]) -> Path {
        var path = Path()
        path.addLines(points.map { Self.viewPoint(for: $0, scale: scale) })
        return path
    }

    private func polygon(_ points: [PlanPoint]) -> Path {
        var path = line(points)
        path.closeSubpath()
        return path
    }

    private var accessibilitySummary: String {
        let zones = floor.zones.map { zone -> String in
            let people = zoneBadges[zone.id] ?? []
            return people.isEmpty ? zone.name : "\(zone.name): \(people.joined(separator: ", "))"
        }
        return ([floor.name] + zones + floor.pointsOfInterest.map(\.name)).joined(separator: "; ")
    }
}
