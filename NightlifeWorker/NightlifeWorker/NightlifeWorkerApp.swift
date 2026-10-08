//
//  NightlifeWorkerApp.swift
//  NightlifeWorker
//
//  Created by Majoros Máté on 2026. 06. 14..
//
import SwiftUI

@main
struct NightlifeWorkerApp: App {
    @StateObject private var authViewModel = AuthViewModel(store: KeychainCredentialStore())

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    HomeView(viewModel: authViewModel)
                } else {
                    WelcomeView(viewModel: authViewModel)
                }
            }
            .task {
                authViewModel.checkAuthState()
            }
        }
    }
}
