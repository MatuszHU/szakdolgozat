import SwiftUI
import AuthenticationServices
import SharedKit

@K1 @K2
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
            #if DEBUG
            Button {
                viewModel.signInWithApple(userID: "debug-worker")
            } label: {
                Text("Belépés (teszt)")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 50)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 32)
            #else
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                switch result {
                case .success(let authorization):
                    if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
                        viewModel.signInWithApple(userID: credential.user)
                    } else {
                        viewModel.cancelSignIn()
                    }
                case .failure:
                    viewModel.cancelSignIn()
                }
            }
            .frame(height: 50)
            .padding(.horizontal, 32)
            #endif
            Spacer().frame(height: 32)
        }
    }
}
