import SwiftUI
import SharedKit

@L2 @L5
struct ContentView: View {
    @ObservedObject var session: AdminSessionViewModel

    enum Section: Hashable {
        case designer
        case zoneCodes
        case staffMap
        case shiftPlanner
        case events
        case inventory
        case requests
        case admins
        case settings
    }

    @StateObject private var designer: VenueDesignerViewModel = {
        let store = LocalJSONStore<Venue>(fileName: "venue.json")
        return VenueDesignerViewModel(venue: store.load() ?? Venue(name: "Helyszín"), store: store)
    }()
    @StateObject private var planner: ShiftPlannerViewModel = {
        let store = LocalJSONStore<ShiftPlan>(fileName: "shift-plan.json")
        return ShiftPlannerViewModel(plan: store.load() ?? ShiftPlan(), store: store)
    }()
    @StateObject private var events: EventManagerViewModel = {
        let store = LocalJSONStore<EventCatalog>(fileName: "events.json")
        return EventManagerViewModel(catalog: store.load() ?? EventCatalog(), store: store)
    }()
    @StateObject private var inventory: InventoryViewModel = {
        let store = LocalJSONStore<Inventory>(fileName: "inventory.json")
        return InventoryViewModel(inventory: store.load() ?? Inventory(), store: store)
    }()
    @State private var section: Section? = .designer

    var body: some View {
        NavigationSplitView {
            List(selection: $section) {
                Label("Helyszíntervező", systemImage: "square.grid.3x3").tag(Section.designer)
                Label("Zónakódok", systemImage: "qrcode").tag(Section.zoneCodes)
                Label("Személyzet térképe", systemImage: "person.2.badge.gearshape").tag(Section.staffMap)
                Label("Műszakok", systemImage: "calendar.badge.clock").tag(Section.shiftPlanner)
                Label("Események", systemImage: "ticket").tag(Section.events)
                Label("Készlet", systemImage: "shippingbox").tag(Section.inventory)
                Label("Kérelmek", systemImage: "tray.full").tag(Section.requests)
                Label("Adminisztrátorok", systemImage: "person.2").tag(Section.admins)
                Label("Beállítások", systemImage: "gearshape").tag(Section.settings)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .safeAreaInset(edge: .bottom) {
                if let admin = session.currentAdmin {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(admin.name).font(.headline)
                        Text(AdminsView.title(of: admin.role)).foregroundStyle(.secondary)
                        Button("Kijelentkezés", systemImage: "rectangle.portrait.and.arrow.right") { session.signOut() }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        } detail: {
            switch section {
            case .zoneCodes: ZoneCodeSheetView(viewModel: designer)
            case .staffMap: StaffMapView(venue: designer.venue, plan: planner.plan).id([designer.venue.hashValue, planner.plan.hashValue])
            case .shiftPlanner: ShiftPlannerView(viewModel: planner, venue: designer.venue)
            case .events: EventsView(viewModel: events, defaultLocation: designer.venue.name)
            case .inventory: InventoryView(viewModel: inventory)
            case .requests: RequestLogView(inventory: inventory.inventory, staff: planner.plan.staff).id([inventory.inventory.hashValue, planner.plan.hashValue])
            case .admins: AdminsView(session: session)
            case .settings: AdminSettingsView(session: session)
            default: VenueDesignerView(viewModel: designer)
            }
        }
    }
}
