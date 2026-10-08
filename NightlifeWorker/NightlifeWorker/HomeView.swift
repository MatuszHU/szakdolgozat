//
//  HomeView.swift
//  NightlifeWorker
//
//  Created by Majoros Máté on 2026. 06. 27..
//


import SwiftUI
import SharedKit

struct HomeView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var confirmingSignOut = false

    // Until CloudKit sync (N2) there is no real event, ticket or zone data on the device.
    @StateObject private var codeReader = CodeReaderViewModel(
        eventID: UUID(),
        tickets: LocalTicketRepository(),
        zoneCheckIn: ZoneCheckInViewModel(workerID: UUID(), zones: [], isOnShift: false))
    @StateObject private var venueMap = VenueMapViewModel(
        venue: Venue(name: ""),
        me: WorkerUser(appleID: "", name: "", role: .bartender, payPeriod: .weekly),
        colleagues: [],
        checkIns: [],
        assignedZoneID: nil)

    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    CodeReaderView(viewModel: codeReader)
                } label: {
                    Label("Kódolvasó", systemImage: "qrcode.viewfinder")
                }
                NavigationLink {
                    VenueMapView(viewModel: venueMap)
                } label: {
                    Label("Térkép", systemImage: "map")
                }
            }
            .navigationTitle("Nightlife Worker")
            .toolbar {
                Button("Kijelentkezés", systemImage: "rectangle.portrait.and.arrow.right") {
                    confirmingSignOut = true
                }
            }
            .confirmationDialog("Biztosan kijelentkezel?", isPresented: $confirmingSignOut, titleVisibility: .visible) {
                Button("Kijelentkezés", role: .destructive) { viewModel.signOut() }
            }
        }
    }
}
