//
//  Playlist.swift
//  Spotify
//
//  Created by Anthony Kim on 3/15/21.
//

import Foundation

struct Playlist: Codable {
    let description: String
    let external_urls: [String: String]
    let id: String
    let images: [APIImage]
    let name: String
    let owner: User
}
