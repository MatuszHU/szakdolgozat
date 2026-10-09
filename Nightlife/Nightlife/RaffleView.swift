import SwiftUI
import SharedKit

@M7
struct RaffleView: View {
    @ObservedObject var viewModel: RaffleViewModel

    var body: some View {
        List {
            if viewModel.raffles.isEmpty {
                ContentUnavailableView("Nincs aktuális nyereményjáték", systemImage: "gift",
                                       description: Text("A nyereményjátékokat a szervezők hirdetik meg."))
            }
            ForEach(viewModel.raffles) { item in
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.raffle.title).font(.headline)
                        Label(item.raffle.prize, systemImage: "gift")
                        if !item.raffle.details.isEmpty {
                            Text(item.raffle.details).font(.subheadline).foregroundStyle(.secondary)
                        }
                        Text("Jelentkezők: \(item.raffle.participantIDs.count)").font(.caption).foregroundStyle(.secondary)
                    }
                    if item.isEntered {
                        Label("Jelentkeztél", systemImage: "checkmark.seal.fill").foregroundStyle(.green)
                    } else {
                        Button("Jelentkezem") { viewModel.register(forEvent: item.event.id) }
                    }
                } header: {
                    Text("\(item.event.title) · \(item.event.startTime.formatted(date: .abbreviated, time: .shortened))")
                }
            }
            if let message = viewModel.message {
                Text(message).foregroundStyle(viewModel.isError ? .red : .green)
            }
        }
        .navigationTitle("Nyereményjáték")
    }
}
