import Foundation

@L3 @K5
public struct Task: Identifiable, Codable, Hashable {
    public let id: UUID
    public var title: String
    public var description: String
    public var isCompleted: Bool
    public var assignedWorkerIDs: [UUID]
    public var workstation: String
    
    public init(id: UUID = UUID(), title: String, description: String, isCompleted: Bool = false, assignedWorkerIDs: [UUID] = [], workstation: String) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.assignedWorkerIDs = assignedWorkerIDs
        self.workstation = workstation
    }
}
