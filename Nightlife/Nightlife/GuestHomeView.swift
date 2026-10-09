import SwiftUI
import SharedKit

@M3 @M4 @M6 @M7 @M8 @M9
struct GuestHomeView: View {
    @ObservedObject var viewModel: AuthViewModel
    @StateObject private var guestMap = GuestMapViewModel(venue: Venue(name: ""))
    @StateObject private var ticketShop: TicketShopViewModel
    @StateObject private var raffle: RaffleViewModel
    @StateObject private var profilePicture = ProfilePictureViewModel(store: FileProfilePictureStore())

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
        _raffle = StateObject(wrappedValue: RaffleViewModel(
            catalog: EventCatalog(),
            guestID: GuestUser.stableID(forAppleID: viewModel.userID ?? "")))
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
                    RaffleView(viewModel: raffle)
                } label: {
                    Label("Nyereményjáték", systemImage: "gift")
                }
                NavigationLink {
                    GuestMapView(viewModel: guestMap)
                } label: {
                    Label("Térkép", systemImage: "map")
                }
            }
            .navigationTitle("Nightlife")
            .toolbar {
                NavigationLink {
                    GuestSettingsView(viewModel: GuestSettingsViewModel(auth: viewModel, guestName: nil),
                                      profilePicture: profilePicture)
                } label: {
                    Label("Beállítások", systemImage: "gearshape")
                }
            }
        }
    }
}
