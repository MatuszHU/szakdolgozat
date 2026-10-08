import Foundation

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
