import SwiftUI
import SharedKit

@L7
struct VenueDesignerView: View {
    private enum DragAction {
        case move
        case point(Int)
        case nothing
    }

    @ObservedObject var viewModel: VenueDesignerViewModel
    @State private var scale: CGFloat = 28
    @State private var hoverPoint: PlanPoint?
    @State private var dragAction: DragAction?
    @State private var dragTranslation = CGSize.zero
    @State private var dragLocation: PlanPoint?
    @State private var showingNewFloor = false

    var body: some View {
        Group {
            if let floor = viewModel.floor {
                editor(for: floor)
            } else {
                ContentUnavailableView {
                    Label("Még nincs szint", systemImage: "square.dashed")
                } description: {
                    Text("Adj hozzá egy szintet a tervrajz megrajzolásához.")
                } actions: {
                    Button("Új szint") { showingNewFloor = true }
                }
            }
        }
        .navigationTitle("Helyszíntervező")
        .toolbar {
            ToolbarItem {
                Picker("Szint", selection: Binding(get: { viewModel.floor?.id }, set: { viewModel.selectFloor($0) })) {
                    ForEach(viewModel.venue.floors) { floor in
                        Text("\(floor.name) (\(floor.level))").tag(Optional(floor.id))
                    }
                }
            }
            ToolbarItem {
                Picker("Eszköz", selection: $viewModel.tool) {
                    Label("Kijelölés", systemImage: "cursorarrow").tag(VenueDesignerViewModel.Tool.select)
                    Label("Sokszög", systemImage: "pentagon").tag(VenueDesignerViewModel.Tool.polygon)
                    Label("Fal", systemImage: "line.diagonal").tag(VenueDesignerViewModel.Tool.wall)
                }
                .pickerStyle(.segmented)
                .help("Kijelölés, sokszög (zóna vagy hely) és fal rajzolása")
            }
            ToolbarItem {
                Toggle(isOn: $viewModel.snapsToGrid) {
                    Label("Illesztés a pontrácshoz", systemImage: "circle.grid.3x3")
                }
                .toggleStyle(.button)
                .help("A pontok a rács pontjaihoz illeszkednek")
            }
            ToolbarItem {
                ControlGroup {
                    Button("Kicsinyítés", systemImage: "minus.magnifyingglass") { scale = max(scale - 6, 10) }
                    Button("Nagyítás", systemImage: "plus.magnifyingglass") { scale = min(scale + 6, 80) }
                }
            }
            ToolbarItem {
                Button("Új szint", systemImage: "plus") { showingNewFloor = true }
            }
        }
        .sheet(isPresented: $showingNewFloor) {
            NewFloorSheet { name, level, width, height in
                viewModel.addFloor(named: name, level: level, width: width, height: height)
            }
        }
        .sheet(isPresented: Binding(get: { viewModel.closedOutline != nil },
                                    set: { if !$0 { viewModel.cancelDrawing() } })) {
            NewShapeSheet(errorMessage: viewModel.errorMessage,
                          onSave: { name, kind in viewModel.saveShape(named: name, as: kind) },
                          onCancel: { viewModel.cancelDrawing() })
        }
    }

    private func editor(for floor: Floor) -> some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                ScrollView([.horizontal, .vertical]) {
                    FloorPlanView(floor: preview(of: floor),
                                  scale: scale,
                                  selection: viewModel.selection,
                                  draft: draftPreview,
                                  draftIsWall: viewModel.tool == .wall)
                        .contentShape(Rectangle())
                        .gesture(pointer)
                        .onContinuousHover { phase in
                            switch phase {
                            case .active(let location): hoverPoint = FloorPlanView.planPoint(at: location, scale: scale)
                            case .ended: hoverPoint = nil
                            }
                        }
                        .padding(24)
                }
                Divider()
                statusBar
            }
            Divider()
            shapeList(for: floor)
                .frame(width: 260)
        }
    }

    private var draftPreview: [PlanPoint] {
        guard !viewModel.draft.isEmpty, let hoverPoint, let position = viewModel.position(of: hoverPoint) else {
            return viewModel.draft
        }
        return viewModel.draft + [position]
    }

    private func preview(of floor: Floor) -> Floor {
        guard let selection = viewModel.selection, let dragAction else { return floor }
        var preview = floor
        switch dragAction {
        case .move:
            try? preview.move(selection, dx: viewModel.offset(Double(dragTranslation.width / scale)),
                              dy: viewModel.offset(Double(dragTranslation.height / scale)))
        case .point(let index):
            if let dragLocation, let position = viewModel.position(of: dragLocation) {
                try? preview.movePoint(index, of: selection, to: position)
            }
        case .nothing:
            break
        }
        return preview
    }

    private var pointer: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard viewModel.tool == .select else { return }
                if dragAction == nil {
                    let start = FloorPlanView.planPoint(at: value.startLocation, scale: scale)
                    if let index = viewModel.pointIndex(near: start) {
                        dragAction = .point(index)
                    } else {
                        if viewModel.floor?.item(at: start) != viewModel.selection { viewModel.click(at: start) }
                        dragAction = viewModel.selection == nil ? .nothing : .move
                    }
                }
                dragTranslation = value.translation
                dragLocation = FloorPlanView.planPoint(at: value.location, scale: scale)
            }
            .onEnded { value in
                let action = dragAction
                dragAction = nil
                dragTranslation = .zero
                dragLocation = nil
                let location = FloorPlanView.planPoint(at: value.location, scale: scale)
                let isClick = hypot(value.translation.width, value.translation.height) < 3
                guard viewModel.tool == .select else {
                    viewModel.click(at: location)
                    return
                }
                switch action {
                case .point(let index)?:
                    if !isClick { viewModel.dragPoint(index, to: location) }
                case .move?:
                    if isClick {
                        viewModel.click(at: location)
                    } else {
                        viewModel.moveSelection(dx: Double(value.translation.width / scale),
                                                dy: Double(value.translation.height / scale))
                    }
                default:
                    viewModel.click(at: location)
                }
            }
    }

    private var statusBar: some View {
        HStack {
            if let message = viewModel.errorMessage {
                Label(message, systemImage: "exclamationmark.triangle").foregroundStyle(.red)
            } else {
                Text(hint).foregroundStyle(.secondary)
            }
            Spacer()
            if !viewModel.draft.isEmpty {
                Button("Utolsó pont visszavonása") { viewModel.undoLastPoint() }
                Button("Mégse") { viewModel.cancelDrawing() }
                    .keyboardShortcut(.cancelAction)
                Button("Kész") { viewModel.finishDrawing() }
                    .keyboardShortcut(.defaultAction)
            }
            if viewModel.selection != nil {
                Button("Törlés", systemImage: "trash", role: .destructive) { viewModel.deleteSelection() }
                    .keyboardShortcut(.delete, modifiers: [])
            }
        }
        .font(.callout)
        .padding(8)
    }

    private var hint: String {
        switch viewModel.tool {
        case .select: return "Kattints egy alakzatra a kijelöléshez. Húzással mozgatható, a sarokpontjai külön húzhatók."
        case .polygon: return "Kattints a sarokpontokra. Az első pontra kattintva vagy Enterrel zárul az alakzat."
        case .wall: return "Kattints a fal töréspontjaira, majd nyomj Entert."
        }
    }

    private func shapeList(for floor: Floor) -> some View {
        List(selection: Binding(get: { viewModel.selection }, set: { viewModel.select($0) })) {
            Section("Zónák") {
                ForEach(floor.zones) { zone in
                    HStack {
                        Text(zone.name)
                        Spacer()
                        Text(Self.area(zone.area)).foregroundStyle(.secondary)
                    }
                    .tag(PlanItem.zone(zone.id))
                }
            }
            Section("Helyek") {
                ForEach(floor.pointsOfInterest) { poi in
                    HStack {
                        Label(poi.name, systemImage: poi.kind.symbolName)
                        Spacer()
                        Text(Self.area(poi.area)).foregroundStyle(.secondary)
                    }
                    .tag(PlanItem.pointOfInterest(poi.id))
                }
            }
            Section("Falak") {
                ForEach(Array(floor.walls.enumerated()), id: \.element.id) { index, wall in
                    Text("Fal \(index + 1)").tag(PlanItem.wall(wall.id))
                }
            }
        }
    }

    private static func area(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0...1))) + " m²"
    }
}

@L7
private struct NewFloorSheet: View {
    let onSave: (String, Int, Double, Double) -> Void
    @State private var name = ""
    @State private var level = 0
    @State private var width = 30
    @State private var height = 20
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            TextField("Név", text: $name)
            Stepper("Szint: \(level)", value: $level, in: -5...20)
            Stepper("Szélesség: \(width) m", value: $width, in: 2...300)
            Stepper("Mélység: \(height) m", value: $height, in: 2...300)
        }
        .padding()
        .frame(minWidth: 320)
        .navigationTitle("Új szint")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Mégse") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Hozzáadás") {
                    onSave(name, level, Double(width), Double(height))
                    dismiss()
                }
                .disabled(name.isEmpty)
            }
        }
    }
}

@L7
private struct NewShapeSheet: View {
    static let kinds: [(kind: VenueDesignerViewModel.ShapeKind, title: String, symbol: String)] = [
        (.zone, "Zóna (munkaterület QR-kóddal)", "square.dashed"),
        (.pointOfInterest(.bar), "Bár", POIKind.bar.symbolName),
        (.pointOfInterest(.toilet), "Mosdó", POIKind.toilet.symbolName),
        (.pointOfInterest(.stage), "Színpad", POIKind.stage.symbolName),
        (.pointOfInterest(.entrance), "Bejárat", POIKind.entrance.symbolName),
        (.pointOfInterest(.emergencyExit), "Vészkijárat", POIKind.emergencyExit.symbolName),
        (.pointOfInterest(.cloakroom), "Ruhatár", POIKind.cloakroom.symbolName),
        (.pointOfInterest(.custom("other")), "Egyéb (csak a személyzet látja)", POIKind.custom("other").symbolName),
    ]

    let errorMessage: String?
    let onSave: (String, VenueDesignerViewModel.ShapeKind) -> Void
    let onCancel: () -> Void
    @State private var name = ""
    @State private var kindIndex = 0

    var body: some View {
        Form {
            Picker("Típus", selection: $kindIndex) {
                ForEach(Self.kinds.indices, id: \.self) { index in
                    Label(Self.kinds[index].title, systemImage: Self.kinds[index].symbol).tag(index)
                }
            }
            TextField("Név", text: $name)
            if let errorMessage {
                Text(errorMessage).foregroundStyle(.red)
            }
        }
        .padding()
        .frame(minWidth: 360)
        .navigationTitle("Új alakzat")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Mégse", action: onCancel) }
            ToolbarItem(placement: .confirmationAction) {
                Button("Hozzáadás") { onSave(name, Self.kinds[kindIndex].kind) }.disabled(name.isEmpty)
            }
        }
    }
}
