//
//  SettingsModels.swift
//  Spotify
//
//  Created by Anthony Kim on 3/16/21.
//

import Foundation

struct Section {
    let title: String
    let options: [Option]
}

struct Option {
    let title: String
    let handler: () -> Void
}
