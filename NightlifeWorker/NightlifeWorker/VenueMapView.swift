import SwiftUI
import SharedKit

@K6
struct VenueMapView: View {
    @ObservedObject var viewModel: VenueMapViewModel

    var body: some View {
        Group {
            if let floor = viewModel.selectedFloor {
                GeometryReader { proxy in
                    ScrollView([.horizontal, .vertical]) {
                        FloorPlanView(floor: floor,
                                      scale: FloorPlanView.fittingScale(for: floor, in: CGSize(width: proxy.size.width - 32,
                                                                                               height: .infinity)),
                                      highlightedZoneID: viewModel.workAreaZoneID,
                                      zoneBadges: viewModel.zoneBadges)
                            .padding()
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    if !viewModel.colleaguesWithoutPosition.isEmpty {
                        Text("Nincs bejelentkezve: \(viewModel.colleaguesWithoutPosition.map(\.name).joined(separator: ", "))")
                            .font(.footnote)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.regularMaterial)
                    }
                }
            } else {
                ContentUnavailableView("Még nincs tervrajz",
                                       systemImage: "map",
                                       description: Text("A helyszín tervrajzát az adminisztrátor készíti el."))
            }
        }
        .navigationTitle("Térkép")
        .toolbar {
            if viewModel.venue.floors.count > 1 {
                ToolbarItem(placement: .principal) {
                    Picker("Szint", selection: Binding(get: { viewModel.selectedFloorID },
                                                       set: { if let id = $0 { viewModel.selectFloor(id: id) } })) {
                        ForEach(viewModel.venue.floors) { Text($0.name).tag(Optional($0.id)) }
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
    }
}
