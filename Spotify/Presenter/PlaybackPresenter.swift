//
//  PlaybackPresenter.swift
//  Spotify
//
//  Created by Anthony Kim on 6/5/21.
//

import Foundation
import UIKit
import AVFoundation

// hook up getting the name, subtitle, image into the controller
// we are going to do this by creating datasource protocol
protocol PlayerDataSource: AnyObject {
    var songName: String? { get }
    var subtitle: String? { get }
    var imageURL: URL? { get }
}

// have this presenter actually conform
final class PlaybackPresenter {
    //    can have singleton or static function directly
    static let shared = PlaybackPresenter() // shared instance approach; simpler in terms of actual implementation
    // now we can hold instance property in this class instead of doing everything statically
    
    // whenever we want to call this function we want to hold on to the reference to whichever track
    // we are currently playing
    private var track: AudioTrack?
    private var tracks = [AudioTrack]() // empty in the beginning
    
    var index = 0
    
    var currentTrack: AudioTrack? {
        if let track = track, tracks.isEmpty {
            return track
        } else if let player = self.playerQueue, !tracks.isEmpty {
            
            return tracks[index] // from our track the nth index track
        }
        return nil
    }
    
    var playerVC: PlayerViewController?
    
    var player: AVPlayer?
    var playerQueue: AVQueuePlayer?
    
    
     func startPlayback(from viewController: UIViewController,
                              track: AudioTrack) {
        guard let url = URL(string: track.preview_url ?? "") else {
            return
        }
        player = AVPlayer(url: url)
        player?.volume = 0.5
        
        self.track = track
        self.tracks = []
        let vc = PlayerViewController()
        vc.title = track.name
        vc.dataSource = self // implies this class needs to implement the datasource protocol
        vc.delegate = self
        viewController.present(UINavigationController(rootViewController: vc), animated: true) { [weak self] in
            // start playing the audio
            self?.player?.play()
        }
        self.playerVC = vc
    }
    
     func startPlayback(from viewController: UIViewController,
                              tracks: [AudioTrack]) {
        // reset information here for the models
        // but instead of using avplayer
        // we want to have playerqueue.
        
        self.tracks = tracks
        self.track = nil
        
        
        self.playerQueue = AVQueuePlayer(items: tracks.compactMap({
            guard let url = URL(string: $0.preview_url ?? "") else {
                return nil
            }
            return AVPlayerItem(url: url)
        }))
        self.playerQueue?.volume = 0.2 // zero for copy right purposes
        self.playerQueue?.play()
        
        // album and playlist is collection of multiple tracks at the end of the day
        let vc = PlayerViewController()
        vc.dataSource = self
        vc.delegate = self
        viewController.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
        self.playerVC = vc
    }

}

extension PlaybackPresenter: PlayerViewControllerDelegate {
    
    func didTapPlayPause() {
        if let player = player {
            if player.timeControlStatus == .playing {
                player.pause()
            } else if player.timeControlStatus == .paused {
                player.play()
            }
        }
        else if let player = playerQueue {
            // figure out if the player is playing
            if player.timeControlStatus == .playing {
                player.pause()
            } else if player.timeControlStatus == .paused {
                player.play()
            }
        }
    }
    
    func didTapForward() {
        if tracks.isEmpty {
            // mean there is not collection to play. so not a playlist or album
            player?.pause()
        } else if let player = playerQueue {
            playerQueue?.advanceToNextItem()
            index += 1
            print(index)
            playerVC?.refreshUI()
        }
    }
    
    func didTapBackward() {
        if tracks.isEmpty {
            // mean there is not collection to play. so not a playlist or album
            player?.pause()
            player?.play()
        } else if let firstItem = playerQueue?.items().first {
            playerQueue?.pause()
            playerQueue?.removeAllItems()
            playerQueue = AVQueuePlayer(items: [firstItem])
            playerQueue?.play()
            playerQueue?.volume = 0.2
        }
    }
    
    func didSlideSlider(_ value: Float) {
        player?.volume = value
    }
}

extension PlaybackPresenter: PlayerDataSource {
    var songName: String? {
        return currentTrack?.name
    }
    
    var subtitle: String? {
        return currentTrack?.artists.first?.name
    }
    
    var imageURL: URL? {
        print("Images: \(currentTrack?.album?.images.first)")
        return URL(string: currentTrack?.album?.images.first?.url ?? "")
    }
    
    
}
