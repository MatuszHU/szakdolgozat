//
//  NightlifeWorkerApp.swift
//  NightlifeWorker
//
//  Created by Majoros Máté on 2026. 06. 14..
//
import SwiftUI

@main
struct NightlifeWorkerApp: App {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                HomeView(viewModel: authViewModel)
            } else {
                WelcomeView(viewModel: authViewModel)
            }
        }
    }
}
