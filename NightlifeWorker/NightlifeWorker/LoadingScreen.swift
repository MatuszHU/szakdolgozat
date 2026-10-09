import SwiftUI
import SharedKit

@K3
struct LoadingScreen: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 64))
                .foregroundStyle(.purple)
                .symbolEffect(.pulse, options: .repeating)
            ProgressView()
            Text("Betöltés…").font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
        .accessibilityElement(children: .combine)
        .transition(.opacity)
    }
}
