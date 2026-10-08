//
//  VenueDesignerView.swift
//  NightlifeManager
//
//  Created by Majoros Máté on 2026. 10. 08..
//


import SwiftUI
import SharedKit

/// Grid editor: drag to draw a zone, click to place a point of interest (L7).
struct VenueDesignerView: View {
    enum Tool: String, CaseIterable, Identifiable {
        case zone = "Zóna"
        case pointOfInterest = "Pont"
        var id: Self { self }
    }

    struct PendingCells: Identifiable {
        let id = UUID()
        let floorID: UUID
        let from: GridCell
        let to: GridCell
    }

    private static let cellSize: CGFloat = 32

    @ObservedObject var viewModel: VenueDesignerViewModel
    @State private var selectedFloorID: UUID?
    @State private var tool = Tool.zone
    @State private var dragStart: GridCell?
    @State private var dragEnd: GridCell?
    @State private var pendingZone: PendingCells?
    @State private var pendingPoint: PendingCells?
    @State private var showingNewFloor = false

    private var floor: Floor? {
        viewModel.venue.floors.first { $0.id == selectedFloorID } ?? viewModel.venue.floors.first
    }

    var body: some View {
        Group {
            if let floor {
                editor(for: floor)
            } else {
                ContentUnavailableView {
                    Label("Még nincs szint", systemImage: "square.grid.3x3")
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
                Picker("Szint", selection: Binding(get: { floor?.id }, set: { selectedFloorID = $0 })) {
                    ForEach(viewModel.venue.floors) { floor in
                        Text("\(floor.name) (\(floor.level))").tag(Optional(floor.id))
                    }
                }
            }
            ToolbarItem {
                Picker("Eszköz", selection: $tool) {
                    ForEach(Tool.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
            }
            ToolbarItem {
                Button("Új szint", systemImage: "plus") { showingNewFloor = true }
            }
        }
        .sheet(isPresented: $showingNewFloor) {
            NewFloorSheet { name, level, width, height in
                viewModel.addFloor(named: name, level: level, width: width, height: height)
                selectedFloorID = viewModel.venue.floors.first { $0.level == level }?.id
            }
        }
        .sheet(item: $pendingZone) { pending in
            NameSheet(title: "Új zóna") { name in
                viewModel.drawZone(named: name, from: pending.from, to: pending.to, onFloor: pending.floorID)
            }
        }
        .sheet(item: $pendingPoint) { pending in
            NewPointSheet { name, kind in
                viewModel.placePointOfInterest(named: name, kind: kind, at: pending.from, onFloor: pending.floorID)
            }
        }
    }

    private func editor(for floor: Floor) -> some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading) {
                ScrollView([.horizontal, .vertical]) {
                    FloorPlanView(floor: floor, selection: selection(on: floor), cellSize: Self.cellSize)
                        .gesture(drawing(on: floor))
                        .padding()
                }
                if let message = viewModel.errorMessage {
                    Label(message, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                        .padding()
                }
            }
            Divider()
            List {
                Section("Zónák") {
                    ForEach(floor.zones) { zone in
                        HStack {
                            Text(zone.name)
                            Spacer()
                            Text("\(zone.cells.count) cella").foregroundStyle(.secondary)
                            Button("Törlés", systemImage: "trash", role: .destructive) {
                                viewModel.removeZone(id: zone.id, onFloor: floor.id)
                            }
                            .labelStyle(.iconOnly)
                            .buttonStyle(.borderless)
                        }
                    }
                }
                Section("Pontok") {
                    ForEach(floor.pointsOfInterest) { poi in
                        HStack {
                            Label(poi.name, systemImage: poi.kind.symbolName)
                            Spacer()
                            Button("Törlés", systemImage: "trash", role: .destructive) {
                                viewModel.removePointOfInterest(id: poi.id, onFloor: floor.id)
                            }
                            .labelStyle(.iconOnly)
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
            .frame(width: 260)
        }
    }

    private func selection(on floor: Floor) -> Set<GridCell> {
        guard let dragStart, let dragEnd, tool == .zone else { return [] }
        return Floor.cells(from: dragStart, to: dragEnd).filter(floor.contains)
    }

    private func drawing(on floor: Floor) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                dragStart = FloorPlanView.cell(at: value.startLocation, cellSize: Self.cellSize)
                dragEnd = FloorPlanView.cell(at: value.location, cellSize: Self.cellSize)
            }
            .onEnded { _ in
                guard let start = dragStart, let end = dragEnd else { return }
                dragStart = nil
                dragEnd = nil
                switch tool {
                case .zone: pendingZone = PendingCells(floorID: floor.id, from: start, to: end)
                case .pointOfInterest: pendingPoint = PendingCells(floorID: floor.id, from: end, to: end)
                }
            }
    }
}

private struct NameSheet: View {
    let title: String
    let onSave: (String) -> Void
    @State private var name = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            TextField("Név", text: $name)
        }
        .padding()
        .frame(minWidth: 320)
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Mégse") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Hozzáadás") { onSave(name); dismiss() }.disabled(name.isEmpty)
            }
        }
    }
}

private struct NewFloorSheet: View {
    let onSave: (String, Int, Int, Int) -> Void
    @State private var name = ""
    @State private var level = 0
    @State private var width = 12
    @State private var height = 8
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            TextField("Név", text: $name)
            Stepper("Szint: \(level)", value: $level, in: -5...20)
            Stepper("Szélesség: \(width) cella", value: $width, in: 1...60)
            Stepper("Magasság: \(height) cella", value: $height, in: 1...60)
        }
        .padding()
        .frame(minWidth: 320)
        .navigationTitle("Új szint")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Mégse") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Hozzáadás") { onSave(name, level, width, height); dismiss() }.disabled(name.isEmpty)
            }
        }
    }
}

private struct NewPointSheet: View {
    static let kinds: [(kind: POIKind, title: String)] = [
        (.bar, "Bár"), (.toilet, "Mosdó"), (.stage, "Színpad"), (.entrance, "Bejárat"),
        (.emergencyExit, "Vészkijárat"), (.cloakroom, "Ruhatár"),
    ]

    let onSave: (String, POIKind) -> Void
    @State private var name = ""
    @State private var kindIndex = 0
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            TextField("Név", text: $name)
            Picker("Típus", selection: $kindIndex) {
                ForEach(Self.kinds.indices, id: \.self) { index in
                    Label(Self.kinds[index].title, systemImage: Self.kinds[index].kind.symbolName).tag(index)
                }
            }
        }
        .padding()
        .frame(minWidth: 320)
        .navigationTitle("Új pont")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Mégse") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Hozzáadás") { onSave(name, Self.kinds[kindIndex].kind); dismiss() }.disabled(name.isEmpty)
            }
        }
    }
}
