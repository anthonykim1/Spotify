//
//  SearchResult.swift
//  Spotify
//
//  Created by Anthony Kim on 6/3/21.
//

import Foundation

// we are going to have one object that can maintain different type of search result
enum SearchResult {
    case artist(model: Artist) // have associated inner model for itself
    case album(model: Album)
    case track(model: AudioTrack)
    case playlist(model: Playlist)
}
