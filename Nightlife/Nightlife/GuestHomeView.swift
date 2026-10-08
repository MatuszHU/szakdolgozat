import SwiftUI
import SharedKit

@M3 @M6
struct GuestHomeView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var confirmingSignOut = false

    var body: some View {
        NavigationStack {
            ContentUnavailableView("Üdv a Nightlife-ban!",
                                   systemImage: "sparkles",
                                   description: Text("Hamarosan itt találod a jegyeidet, a helyszín térképét és a nyereményjátékokat."))
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
