import Foundation
import CryptoKit

@M2 @M4
public struct GuestUser: Identifiable, Codable {
    public let id: UUID
    public let appleID: String
    public var name: String
    public var profileImageURL: URL?
    public var tickets: [Ticket]
    
    public init(id: UUID = UUID(), appleID: String, name: String, profileImageURL: URL? = nil, tickets: [Ticket] = []) {
        self.id = id
        self.appleID = appleID
        self.name = name
        self.profileImageURL = profileImageURL
        self.tickets = tickets
    }
}

extension GuestUser {
    @M4 @M2
    public static func stableID(forAppleID appleID: String) -> UUID {
        let bytes = Array(SHA256.hash(data: Data(appleID.utf8)).prefix(16))
        return UUID(uuid: (bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7],
                           bytes[8], bytes[9], bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]))
    }
}
