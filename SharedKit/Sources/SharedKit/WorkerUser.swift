//
//  Worker.swift
//  
//
//  Created by Majoros Máté on 2026. 06. 14..
//


import Foundation

public enum WorkerRole: Codable {
    case bartender
    case security
    case custom(String)
}

public enum PayPeriod: Codable {
    case weekly
    case biweekly
    case monthly
    case custom(Int)
}

public struct WorkerUser: Identifiable, Codable {
    public let id: UUID
    public let appleID: String
    public var name: String
    public var profileImageURL: URL?
    public var role: WorkerRole
    public var shifts: [Shift]
    public var workedHours: Double
    public var payPeriod: PayPeriod
    
    public init(id: UUID = UUID(), appleID: String, name: String, profileImageURL: URL? = nil, role: WorkerRole, shifts: [Shift] = [], workedHours: Double = 0, payPeriod: PayPeriod) {
        self.id = id
        self.appleID = appleID
        self.name = name
        self.profileImageURL = profileImageURL
        self.role = role
        self.shifts = shifts
        self.workedHours = workedHours
        self.payPeriod = payPeriod
    }
}
