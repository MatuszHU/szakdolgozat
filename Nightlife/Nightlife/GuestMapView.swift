import SwiftUI
import SharedKit

@M5
struct GuestMapView: View {
    @ObservedObject var viewModel: GuestMapViewModel

    var body: some View {
        Group {
            if let floor = viewModel.selectedFloor {
                List {
                    Section {
                        ScrollView([.horizontal, .vertical]) {
                            FloorPlanView(floor: floor, cellSize: 36).padding()
                        }
                        .frame(minHeight: 280)
                    }
                    Section("Helyek") {
                        ForEach(viewModel.places) { place in
                            Label(place.name, systemImage: place.kind.symbolName)
                        }
                    }
                }
            } else {
                ContentUnavailableView("A térkép még nem elérhető",
                                       systemImage: "map",
                                       description: Text("A helyszín tervrajza hamarosan itt lesz."))
            }
        }
        .navigationTitle("Térkép")
        .toolbar {
            if viewModel.floors.count > 1 {
                ToolbarItem(placement: .principal) {
                    Picker("Szint", selection: Binding(get: { viewModel.selectedFloorID },
                                                       set: { if let id = $0 { viewModel.selectFloor(id: id) } })) {
                        ForEach(viewModel.floors) { Text($0.name).tag(Optional($0.id)) }
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
    }
}
