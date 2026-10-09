import SwiftUI
import SharedKit

@K4 @K14 @K5 @K17
struct HomeView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var confirmingSignOut = false

    @StateObject private var codeReader = CodeReaderViewModel(
        eventID: UUID(),
        tickets: LocalTicketRepository(),
        zoneCheckIn: ZoneCheckInViewModel(workerID: UUID(), zones: [], isOnShift: false))
    @StateObject private var menu = HomeMenuViewModel()
    @StateObject private var schedule = ScheduleViewModel(workerID: UUID(), shifts: [], venue: Venue(name: ""))
    @StateObject private var supplyRequest = SupplyRequestViewModel(workerID: UUID(), zoneID: nil, desk: LocalSupplyDesk())
    @StateObject private var venueMap = VenueMapViewModel(
        venue: Venue(name: ""),
        me: WorkerUser(appleID: "", name: "", role: .bartender, payPeriod: .weekly),
        colleagues: [],
        checkIns: [],
        assignedZoneID: nil)

    var body: some View {
        NavigationStack {
            List(menu.items) { item in
                NavigationLink {
                    destination(for: item)
                } label: {
                    label(for: item)
                }
            }
            .navigationTitle("Nightlife Worker")
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

    @ViewBuilder
    private func destination(for item: HomeItem) -> some View {
        switch item {
        case .schedule: ScheduleView(viewModel: schedule)
        case .codeReader: CodeReaderView(viewModel: codeReader)
        case .map: VenueMapView(viewModel: venueMap)
        case .supplyRequest: SupplyRequestView(viewModel: supplyRequest)
        }
    }

    private func label(for item: HomeItem) -> Label<Text, Image> {
        switch item {
        case .schedule: return Label("Beosztás", systemImage: "calendar")
        case .codeReader: return Label("Kódolvasó", systemImage: "qrcode.viewfinder")
        case .map: return Label("Térkép", systemImage: "map")
        case .supplyRequest: return Label("Készletkérés", systemImage: "shippingbox")
        }
    }
}
