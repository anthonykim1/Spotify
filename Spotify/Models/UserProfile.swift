//
//  UserProfile.swift
//  Spotify
//
//  Created by Anthony Kim on 3/15/21.
//

import Foundation

struct UserProfile: Codable {
    let country: String
    let display_name: String
    let email: String
    let explicit_content: [String: Bool]
    let external_urls: [String: String]
    let id: String
    let product: String
    let images: [APIImage]
}

// comment for id -----> a lot of the api calls ask for the user id so it is
// pretty important 

