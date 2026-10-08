import SwiftUI
import SharedKit

@M3 @M4 @M6
struct GuestHomeView: View {
    @ObservedObject var viewModel: AuthViewModel
    @StateObject private var guestMap = GuestMapViewModel(venue: Venue(name: ""))
    @StateObject private var ticketShop: TicketShopViewModel
    @State private var confirmingSignOut = false

    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
        #if DEBUG
        let payment: PaymentProcessing = TestPaymentProcessor()
        #else
        let payment: PaymentProcessing = UnavailablePaymentProcessor()
        #endif
        _ticketShop = StateObject(wrappedValue: TicketShopViewModel(
            catalog: EventCatalog(),
            guestID: GuestUser.stableID(forAppleID: viewModel.userID ?? ""),
            payment: payment))
    }

    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    TicketShopView(viewModel: ticketShop)
                } label: {
                    Label("Jegyvásárlás", systemImage: "cart")
                }
                NavigationLink {
                    MyTicketsView(viewModel: ticketShop)
                } label: {
                    Label("Jegyeim", systemImage: "ticket")
                }
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
