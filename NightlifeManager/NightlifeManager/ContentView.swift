//
//  ContentView.swift
//  NightlifeManager
//
//  Created by Majoros Máté on 2026. 06. 14..
//

import SwiftUI
import SharedKit

struct ContentView: View {
    enum Section: Hashable {
        case designer
        case zoneCodes
        case staffMap
        case shiftPlanner
        case events
    }

    @StateObject private var designer: VenueDesignerViewModel = {
        let store = LocalJSONStore<Venue>(fileName: "venue.json")
        return VenueDesignerViewModel(venue: store.load() ?? Venue(name: "Helyszín"), store: store)
    }()
    @StateObject private var planner: ShiftPlannerViewModel = {
        let store = LocalJSONStore<ShiftPlan>(fileName: "shift-plan.json")
        return ShiftPlannerViewModel(plan: store.load() ?? ShiftPlan(), store: store)
    }()
    @StateObject private var events: EventManagerViewModel = {
        let store = LocalJSONStore<EventCatalog>(fileName: "events.json")
        return EventManagerViewModel(catalog: store.load() ?? EventCatalog(), store: store)
    }()
    @State private var section: Section? = .designer

    var body: some View {
        NavigationSplitView {
            List(selection: $section) {
                Label("Helyszíntervező", systemImage: "square.grid.3x3").tag(Section.designer)
                Label("Zónakódok", systemImage: "qrcode").tag(Section.zoneCodes)
                Label("Személyzet térképe", systemImage: "person.2.badge.gearshape").tag(Section.staffMap)
                Label("Műszakok", systemImage: "calendar.badge.clock").tag(Section.shiftPlanner)
                Label("Események", systemImage: "ticket").tag(Section.events)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        } detail: {
            switch section {
            case .zoneCodes: ZoneCodeSheetView(viewModel: designer)
            case .staffMap: StaffMapView(venue: designer.venue, plan: planner.plan).id([designer.venue.hashValue, planner.plan.hashValue])
            case .shiftPlanner: ShiftPlannerView(viewModel: planner, venue: designer.venue)
            case .events: EventsView(viewModel: events, defaultLocation: designer.venue.name)
            default: VenueDesignerView(viewModel: designer)
            }
        }
    }
}
