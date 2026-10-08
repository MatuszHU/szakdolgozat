import Foundation

@K7 @K16
public enum ScannedCode: Equatable {
    case zone(UUID)
    case ticket(serialNumber: String)
    case unknown

    public init(payload: String) {
        if let zoneID = Zone.zoneID(fromQRPayload: payload) {
            self = .zone(zoneID)
        } else if payload.hasPrefix(Ticket.qrPrefix), payload.count > Ticket.qrPrefix.count {
            self = .ticket(serialNumber: String(payload.dropFirst(Ticket.qrPrefix.count)))
        } else {
            self = .unknown
        }
    }
}
