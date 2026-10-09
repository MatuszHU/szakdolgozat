import SwiftUI
import SharedKit

@K13
struct NotificationsView: View {
    @ObservedObject var viewModel: NotificationsViewModel

    var body: some View {
        List {
            Picker("Fajta", selection: $viewModel.kindFilter) {
                Text("Mind").tag(NotificationKind?.none)
                Text("Rendszer").tag(Optional(NotificationKind.system))
                Text("Kollégák").tag(Optional(NotificationKind.user))
                Text("Admin").tag(Optional(NotificationKind.admin))
            }
            .pickerStyle(.segmented)
            .listRowBackground(Color.clear)
            if viewModel.visible.isEmpty {
                ContentUnavailableView("Nincs értesítés", systemImage: "bell.slash")
            }
            ForEach(viewModel.visible) { notification in
                Button {
                    viewModel.markRead(id: notification.id)
                } label: {
                    NotificationRow(notification: notification)
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Értesítések")
        .toolbar {
            Button("Mind olvasott", systemImage: "envelope.open") { viewModel.markAllRead() }
                .disabled(viewModel.unreadCount == 0)
        }
        .onAppear { viewModel.open() }
        .refreshable { viewModel.open() }
    }
}

@K13
private struct NotificationRow: View {
    @Environment(\.locale) private var locale
    let notification: WorkerNotification

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .foregroundStyle(notification.kind == .user ? .red : .accentColor)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(LocalizedStringKey(notification.title)).font(notification.isRead ? .body : .body.bold())
                Text(LocalizedStringKey(notification.body)).font(.subheadline).foregroundStyle(.secondary)
                if let eventDate = notification.eventDate {
                    Text(eventDate.formatted(Date.FormatStyle(date: .abbreviated, time: .shortened).locale(locale))).font(.caption)
                }
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(notification.date.formatted(Date.FormatStyle(date: .omitted, time: .shortened).locale(locale))).font(.caption)
                    .foregroundStyle(.secondary)
                if !notification.isRead {
                    Circle().fill(Color.accentColor).frame(width: 8, height: 8)
                }
            }
        }
        .contentShape(Rectangle())
    }

    private var symbol: String {
        switch notification.kind {
        case .system: return "gearshape"
        case .user: return "exclamationmark.triangle.fill"
        case .admin: return "person.badge.key"
        }
    }
}
