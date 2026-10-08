//
//  ScannedCode.swift
//
//
//  Created by Majoros Máté on 2026. 10. 07..
//


import Foundation

/// The meaning of a code read by the worker's code reader (K7).
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
