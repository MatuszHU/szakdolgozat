//
//  HomeView.swift
//  NightlifeWorker
//
//  Created by Majoros Máté on 2026. 06. 27..
//


import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            Text("Főoldal")
                .navigationTitle("Nightlife Worker")
        }
    }
}
