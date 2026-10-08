import SwiftUI
import AuthenticationServices
import SharedKit

@M1 @M2
struct GuestWelcomeView: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: "sparkles")
                .font(.system(size: 80))
                .foregroundStyle(.pink)
            Text("Nightlife")
                .font(.largeTitle.bold())
            Text("Jegyek, térkép és nyereményjátékok egy helyen.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)
            Spacer()
            #if DEBUG
            Button {
                viewModel.signInWithApple(userID: "debug-guest")
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
