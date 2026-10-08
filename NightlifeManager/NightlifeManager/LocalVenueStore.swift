//
//  LocalVenueStore.swift
//  NightlifeManager
//
//  Created by Majoros Máté on 2026. 10. 08..
//


import Foundation
import SharedKit

/// Saves the venue as JSON in Application Support, until CloudKit sync (N2) is available.
struct LocalVenueStore: VenueStoring {
    private let fileURL: URL

    init(fileURL: URL = LocalVenueStore.defaultFileURL) {
        self.fileURL = fileURL
    }

    static var defaultFileURL: URL {
        URL.applicationSupportDirectory.appending(path: "venue.json")
    }

    func load() -> Venue? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(Venue.self, from: data)
    }

    func save(_ venue: Venue) throws {
        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONEncoder().encode(venue).write(to: fileURL, options: .atomic)
    }
}
