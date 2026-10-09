import SwiftUI

@available(iOS 17.0, macOS 14.0, *)
@K3 @M9
public struct LoadingScreen: View {
    public init() {}

    public var body: some View {
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
