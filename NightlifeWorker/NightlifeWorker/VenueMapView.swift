//
//  VenueMapView.swift
//  NightlifeWorker
//
//  Created by Majoros Máté on 2026. 10. 08..
//


import SwiftUI
import SharedKit

/// Read-only floor plan with the worker's area and colleagues' zones (K6).
struct VenueMapView: View {
    @ObservedObject var viewModel: VenueMapViewModel

    var body: some View {
        Group {
            if let floor = viewModel.selectedFloor {
                ScrollView([.horizontal, .vertical]) {
                    FloorPlanView(floor: floor,
                                  highlightedZoneID: viewModel.workAreaZoneID,
                                  zoneBadges: viewModel.zoneBadges,
                                  cellSize: 36)
                        .padding()
                }
                .safeAreaInset(edge: .bottom) {
                    if !viewModel.colleaguesWithoutPosition.isEmpty {
                        Text("Nincs bejelentkezve: " + viewModel.colleaguesWithoutPosition.map(\.name).joined(separator: ", "))
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
