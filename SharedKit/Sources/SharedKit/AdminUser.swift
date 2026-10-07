//
//  Admin.swift
//  
//
//  Created by Majoros Máté on 2026. 06. 14..
//


import Foundation

public enum AdminRole: Codable {
    case userAdmin
    case businessManager
    case owner
}

public struct AdminUser: Identifiable, Codable {
    public let id: UUID
    public let email: String
    public var name: String
    public var profileImageURL: URL?
    public var role: AdminRole
    
    public init(id: UUID = UUID(), email: String, name: String, profileImageURL: URL? = nil, role: AdminRole) {
        self.id = id
        self.email = email
        self.name = name
        self.profileImageURL = profileImageURL
        self.role = role
    }
}
