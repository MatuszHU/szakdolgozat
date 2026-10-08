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
    }

    @StateObject private var designer: VenueDesignerViewModel = {
        let store = LocalVenueStore()
        return VenueDesignerViewModel(venue: store.load() ?? Venue(name: "Helyszín"), store: store)
    }()
    @State private var section: Section? = .designer

    var body: some View {
        NavigationSplitView {
            List(selection: $section) {
                Label("Helyszíntervező", systemImage: "square.grid.3x3").tag(Section.designer)
                Label("Zónakódok", systemImage: "qrcode").tag(Section.zoneCodes)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        } detail: {
            switch section {
            case .zoneCodes: ZoneCodeSheetView(viewModel: designer)
            default: VenueDesignerView(viewModel: designer)
            }
        }
    }
}
