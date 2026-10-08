import SwiftUI
import SharedKit

@K4 @K14 @K5
struct HomeView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var confirmingSignOut = false

    @StateObject private var codeReader = CodeReaderViewModel(
        eventID: UUID(),
        tickets: LocalTicketRepository(),
        zoneCheckIn: ZoneCheckInViewModel(workerID: UUID(), zones: [], isOnShift: false))
    @StateObject private var schedule = ScheduleViewModel(workerID: UUID(), shifts: [], venue: Venue(name: ""))
    @StateObject private var venueMap = VenueMapViewModel(
        venue: Venue(name: ""),
        me: WorkerUser(appleID: "", name: "", role: .bartender, payPeriod: .weekly),
        colleagues: [],
        checkIns: [],
        assignedZoneID: nil)

    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    ScheduleView(viewModel: schedule)
                } label: {
                    Label("Beosztás", systemImage: "calendar")
                }
                NavigationLink {
                    CodeReaderView(viewModel: codeReader)
                } label: {
                    Label("Kódolvasó", systemImage: "qrcode.viewfinder")
                }
                NavigationLink {
                    VenueMapView(viewModel: venueMap)
                } label: {
                    Label("Térkép", systemImage: "map")
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
}
