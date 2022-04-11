//
//  Restaurant.swift
//  WaitTimes
//
//  Created by JHCS Computer 1 on 3/8/22.
//

import Foundation


struct Restaurant: Codable, Hashable, Identifiable {
    let id: Int
    let name: String
    let address: String
    let website: String?
    let yelpPage: String?
    let phoneNumber: Int?
}

struct User: Codable, Hashable, Identifiable {
    let id: Int
    let username: String
    let firstName: String?
    let lastName: String?
    let email: String?
}

struct Address: Codable, Hashable, Identifiable {
    let id: Int
    let raw: String
    let streetNumber: Int?
    let route: String?
    let locality: String?
}