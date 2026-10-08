//
//  StaffMapView.swift
//  NightlifeManager
//
//  Created by Majoros Máté on 2026. 10. 08..
//


import SwiftUI
import SharedKit

/// Floor plan with staff positions; selecting a worker shows their work area, position and tasks (L4).
struct StaffMapView: View {
    @StateObject private var viewModel: StaffMapViewModel

    init(venue: Venue) {
        // Until CloudKit sync (N2) there are no staff, shifts or check-ins on the Mac.
        _viewModel = StateObject(wrappedValue: StaffMapViewModel(venue: venue, staff: [], checkIns: [], shifts: []))
    }

    var body: some View {
        Group {
            if let floor = viewModel.selectedFloor {
                HStack(spacing: 0) {
                    ScrollView([.horizontal, .vertical]) {
                        FloorPlanView(floor: floor,
                                      highlightedZoneID: selectedEntry?.workAreaZoneID,
                                      zoneBadges: viewModel.zoneBadges)
                            .padding()
                    }
                    Divider()
                    staffList.frame(width: 280)
                }
            } else {
                ContentUnavailableView("Még nincs tervrajz",
                                       systemImage: "map",
                                       description: Text("Készítsd el a helyszín tervrajzát a helyszíntervezőben."))
            }
        }
        .navigationTitle("Személyzet térképe")
        .toolbar {
            ToolbarItem {
                Picker("Szint", selection: Binding(get: { viewModel.selectedFloorID },
                                                   set: { if let id = $0 { viewModel.selectFloor(id: id) } })) {
                    ForEach(viewModel.venue.floors) { Text($0.name).tag(Optional($0.id)) }
                }
            }
        }
    }

    private var selectedEntry: StaffMap.Entry? {
        viewModel.entries.first { $0.worker.id == viewModel.selectedWorkerID }
    }

    private var staffList: some View {
        List(selection: Binding(get: { viewModel.selectedWorkerID },
                                set: { if let id = $0 { viewModel.selectWorker(id: id) } })) {
            Section("Munkatársak") {
                if viewModel.entries.isEmpty {
                    Text("Nincs műszakban lévő munkatárs.").foregroundStyle(.secondary)
                }
                ForEach(viewModel.entries, id: \.worker.id) { entry in
                    Label(entry.worker.name,
                          systemImage: entry.positionZoneID == nil ? "person.crop.circle.badge.questionmark" : "person.crop.circle")
                        .tag(entry.worker.id)
                }
            }
            if let details = viewModel.selectedDetails {
                Section(details.name) {
                    LabeledContent("Munkaterület", value: details.workAreaName ?? "–")
                    LabeledContent("Pozíció", value: details.positionName ?? "Nincs bejelentkezve")
                    ForEach(details.taskTitles, id: \.self) { title in
                        Label(title, systemImage: "checklist")
                    }
                }
            }
        }
    }
}
