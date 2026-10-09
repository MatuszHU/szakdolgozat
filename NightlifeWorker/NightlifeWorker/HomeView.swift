import SwiftUI
import SharedKit

@K4 @K14 @K5 @K17 @K12 @K13 @K9 @K15 @K11
struct HomeView: View {
    @ObservedObject var viewModel: AuthViewModel
    @ObservedObject var language: LanguageSettings
    @StateObject private var profilePicture = ProfilePictureViewModel(store: FileProfilePictureStore())

    @StateObject private var codeReader = CodeReaderViewModel(
        eventID: UUID(),
        tickets: LocalTicketRepository(),
        zoneCheckIn: ZoneCheckInViewModel(workerID: UUID(), zones: [], isOnShift: false))
    @StateObject private var menu = HomeMenuViewModel()
    @StateObject private var schedule = ScheduleViewModel(workerID: UUID(), shifts: [], venue: Venue(name: ""))
    @StateObject private var notifications = NotificationsViewModel(sources: { NotificationSources(workerID: UUID()) })
    @StateObject private var summary = WorkSummaryViewModel(workerID: UUID(), shifts: [], payPeriod: .weekly)
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
                        .badge(item == .notifications ? notifications.unreadCount : 0)
                }
            }
            .navigationTitle("Nightlife Worker")
            .toolbar {
                if menu.showsGuide {
                    ToolbarItem(placement: .topBarLeading) {
                        NavigationLink {
                            GuideView(viewModel: GuideViewModel(menu: menu))
                        } label: {
                            Label("Útmutató", systemImage: "questionmark.circle")
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView(viewModel: SettingsViewModel(auth: viewModel, workerName: nil,
                                                                  enabledFeatures: menu.enabledFeatures),
                                     profilePicture: profilePicture,
                                     language: language,
                                     guide: GuideViewModel(menu: menu))
                    } label: {
                        Label("Beállítások", systemImage: "gearshape")
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func destination(for item: HomeItem) -> some View {
        switch item {
        case .schedule: ScheduleView(viewModel: schedule)
        case .notifications: NotificationsView(viewModel: notifications)
        case .codeReader: CodeReaderView(viewModel: codeReader)
        case .map: VenueMapView(viewModel: venueMap)
        case .supplyRequest: SupplyRequestView(viewModel: supplyRequest)
        case .summary: WorkSummaryView(viewModel: summary)
        }
    }

    private func label(for item: HomeItem) -> Label<Text, Image> {
        Label {
            Text(item.title)
        } icon: {
            Image(systemName: item.symbol)
        }
    }
}
