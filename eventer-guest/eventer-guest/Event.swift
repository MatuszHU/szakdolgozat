import Foundation
import SwiftData

@Model
final class Event {
    var name: String

    init(name: String) {
        self.name = name
    }
}
