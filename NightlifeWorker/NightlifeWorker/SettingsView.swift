import SwiftUI
import SharedKit

@K9
struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @ObservedObject var profilePicture: ProfilePictureViewModel
    let guide: GuideViewModel
    @State private var confirmingSignOut = false

    var body: some View {
        List(viewModel.items) { item in
            row(for: item)
        }
        .navigationTitle("Beállítások")
        .confirmationDialog("Biztosan kijelentkezel?", isPresented: $confirmingSignOut, titleVisibility: .visible) {
            Button("Kijelentkezés", role: .destructive) { viewModel.signOut() }
        }
    }

    @ViewBuilder
    private func row(for item: SettingsItem) -> some View {
        switch item {
        case .profilePicture:
            NavigationLink {
                ProfilePictureView(viewModel: profilePicture)
            } label: {
                HStack {
                    ProfileImage(data: profilePicture.imageData, size: 32)
                    Text("Profilkép")
                }
            }
        case .guide:
            NavigationLink {
                GuideView(viewModel: guide)
            } label: {
                Label("Útmutató", systemImage: "questionmark.circle")
            }
        case .about:
            VStack(alignment: .leading, spacing: 4) {
                Text("Nightlife Worker").font(.headline)
                Text(viewModel.workerName.map { "Bejelentkezve: \($0)" } ?? "Bejelentkezve Apple-fiókkal")
                    .foregroundStyle(.secondary)
                Text("Verzió: \(viewModel.version)").font(.caption).foregroundStyle(.secondary)
            }
        case .signOut:
            Button("Kijelentkezés", systemImage: "rectangle.portrait.and.arrow.right", role: .destructive) {
                confirmingSignOut = true
            }
        }
    }
}
