import SwiftUI
import SharedKit

@M8
struct GuestSettingsView: View {
    @ObservedObject var viewModel: GuestSettingsViewModel
    @ObservedObject var profilePicture: ProfilePictureViewModel
    @ObservedObject var language: LanguageSettings
    @State private var confirmingSignOut = false

    var body: some View {
        List(viewModel.items) { item in
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
            case .language:
                NavigationLink {
                    LanguageView(settings: language)
                } label: {
                    LabeledContent {
                        if let name = language.language.nativeName {
                            Text(verbatim: name)
                        } else {
                            Text("A rendszer nyelve")
                        }
                    } label: {
                        Label("Nyelv", systemImage: "globe")
                    }
                }
            case .tips:
                Button("Tippek újra", systemImage: "lightbulb") { viewModel.showTipsAgain() }
            case .about:
                VStack(alignment: .leading, spacing: 4) {
                    Text("Nightlife").font(.headline)
                    Text(viewModel.guestName.map { "Bejelentkezve: \($0)" } ?? "Bejelentkezve Apple-fiókkal")
                        .foregroundStyle(.secondary)
                    Text("Verzió: \(viewModel.version)").font(.caption).foregroundStyle(.secondary)
                }
            case .signOut:
                Button("Kijelentkezés", systemImage: "rectangle.portrait.and.arrow.right", role: .destructive) {
                    confirmingSignOut = true
                }
            }
        }
        .navigationTitle("Beállítások")
        .confirmationDialog("Biztosan kijelentkezel?", isPresented: $confirmingSignOut, titleVisibility: .visible) {
            Button("Kijelentkezés", role: .destructive) { viewModel.signOut() }
        }
    }
}
