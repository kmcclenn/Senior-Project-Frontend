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

struct SimpleUser: Codable, Hashable {
    let username: String
    let password: String
}

struct WaitTime: Codable, Hashable, Identifiable {
    let id: Int
    let averageWaittimeWithinPast30Minutes: Float
    let waitList: String
}

struct InputWaitTime: Codable, Hashable {
    let restaurant: Int //Restaurant
    let waitLength: Int?
    let reportingUser: Int //Int
    let arrivalTime: String?
    let seatedTime: String?
}

struct InputWaitTimeRead: Identifiable, Codable, Hashable {
    let id: Int
    let restaurant: Int
    let waitLength: Int
    let reportingUser: Int
    let accuracy: Float
    let pointValue: Int
    let postTime: String
    let arrivalTime: String
    let seatedTime: String
}
