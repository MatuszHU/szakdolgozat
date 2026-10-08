//
//  LocalJSONStore.swift
//  NightlifeManager
//
//  Created by Majoros Máté on 2026. 10. 08..
//


import Foundation
import SharedKit

/// Saves a value as JSON in Application Support, until CloudKit sync (N2) is available.
struct LocalJSONStore<Value: Codable> {
    private let fileURL: URL

    init(fileName: String) {
        fileURL = URL.applicationSupportDirectory.appending(path: fileName)
    }

    func load() -> Value? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(Value.self, from: data)
    }

    func save(_ value: Value) throws {
        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONEncoder().encode(value).write(to: fileURL, options: .atomic)
    }
}

extension LocalJSONStore: VenueStoring where Value == Venue {}
extension LocalJSONStore: ShiftPlanStoring where Value == ShiftPlan {}
extension LocalJSONStore: EventCatalogStoring where Value == EventCatalog {}
