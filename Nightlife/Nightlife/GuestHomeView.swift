import SwiftUI
import SharedKit

@M3 @M6
struct GuestHomeView: View {
    @ObservedObject var viewModel: AuthViewModel
    @StateObject private var guestMap = GuestMapViewModel(venue: Venue(name: ""))
    @State private var confirmingSignOut = false

    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    GuestMapView(viewModel: guestMap)
                } label: {
                    Label("Térkép", systemImage: "map")
                }
            }
            .navigationTitle("Nightlife")
            .toolbar {
                Button("Kijelentkezés", systemImage: "rectangle.portrait.and.arrow.right") {
                    confirmingSignOut = true
                }
            }
            .confirmationDialog("Biztosan kijelentkezel?", isPresented: $confirmingSignOut, titleVisibility: .visible) {
                Button("Kijelentkezés", role: .destructive) { viewModel.signOut() }
            }
        }
    }
}
