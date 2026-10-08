import SwiftUI
import CoreImage.CIFilterBuiltins
import SharedKit

@M4 @K7
struct MyTicketsView: View {
    @ObservedObject var viewModel: TicketShopViewModel

    var body: some View {
        Group {
            if viewModel.myTickets.isEmpty {
                ContentUnavailableView("Még nincs jegyed", systemImage: "ticket")
            } else {
                List(viewModel.myTickets, id: \.ticket.id) { item in
                    VStack(spacing: 12) {
                        Text(item.event.title).font(.headline)
                        Text("\(item.ticket.ticketType.displayName) · \(item.event.startTime.formatted(date: .abbreviated, time: .shortened))")
                            .foregroundStyle(.secondary)
                        if let image = TicketCode.image(for: item.ticket.qrPayload) {
                            Image(uiImage: image)
                                .interpolation(.none)
                                .resizable()
                                .frame(width: 180, height: 180)
                        }
                        Text(item.ticket.serialNumber).font(.caption.monospaced())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle("Jegyeim")
    }
}

@M4 @K7
enum TicketCode {
    static func image(for text: String) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(text.utf8)
        filter.correctionLevel = "M"
        guard let output = filter.outputImage?.transformed(by: CGAffineTransform(scaleX: 10, y: 10)),
              let cgImage = CIContext().createCGImage(output, from: output.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
