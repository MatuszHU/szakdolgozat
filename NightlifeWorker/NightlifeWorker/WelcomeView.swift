//
//  WelcomeView.swift
//  NightlifeWorker
//
//  Created by Majoros Máté on 2026. 06. 27..
//


import SwiftUI
import AuthenticationServices

struct WelcomeView: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 80))
                .foregroundStyle(.purple)
            Text("Nightlife Worker")
                .font(.largeTitle.bold())
            Spacer()
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                switch result {
                case .success:
                    viewModel.signInWithApple()
                case .failure:
                    viewModel.cancelSignIn()
                }
            }
            .frame(height: 50)
            .padding(.horizontal, 32)
            Spacer().frame(height: 32)
        }
    }
}