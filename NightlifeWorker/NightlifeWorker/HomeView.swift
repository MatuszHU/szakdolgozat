//
//  HomeView.swift
//  NightlifeWorker
//
//  Created by Majoros Máté on 2026. 06. 27..
//


import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: AuthViewModel

    // Until CloudKit sync (N2) there is no real event, ticket or zone data on the device.
    @StateObject private var codeReader = CodeReaderViewModel(
        eventID: UUID(),
        tickets: LocalTicketRepository(),
        zoneCheckIn: ZoneCheckInViewModel(workerID: UUID(), zones: [], isOnShift: false))

    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    CodeReaderView(viewModel: codeReader)
                } label: {
                    Label("Kódolvasó", systemImage: "qrcode.viewfinder")
                }
            }
            .navigationTitle("Nightlife Worker")
        }
    }
}
