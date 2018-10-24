//
//  PlayerViewController.swift
//  Spotify Demo
//
//  Created by adam.wienconek on 24.10.2018.
//  Copyright © 2018 adam.wienconek. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    
    private var player: SPTAudioStreamingController!
    private let auth = SPTAuth.defaultInstance()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var progressSlider: UISlider!
    
    private var isChangingProgress = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUIWithoutTrack()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleNewSession()
    }
    
    private func updateUI() {
        guard let currentTrack = player.metadata.currentTrack else {
            updateUIWithoutTrack()
            return
        }
        
        titleLabel.text = currentTrack.name
        artistLabel.text = currentTrack.artistName
        
        SPTTrack.track(withURI: URL(string: currentTrack.uri)!, accessToken: auth.session?.accessToken, market: nil) { error, track in
            if let _ = error {
                return
            }
            guard let sptTrack = track as? SPTTrack else {
                return
            }
        }
        
    }
    
    private func updateUIWithoutTrack() {
        titleLabel.text = "Nothing playing"
        artistLabel.text = ""
    }
    
    func handleNewSession() {
        if player == nil {
            player = SPTAudioStreamingController.sharedInstance()
            do {
                try player.start(withClientId: auth.clientID!, audioController: nil, allowCaching: true)
                player.delegate = self
                player.playbackDelegate = self
                player.diskCache = SPTDiskCache(capacity: 1024 * 1024 * 64)
                player.login(withAccessToken: auth.session!.accessToken)
            } catch let error {
                displayErrorMessage(error: error)
                closeSession()
            }
        }
    }
    
    func closeSession() {
        do {
            try player.stop()
        } catch let error {
            displayErrorMessage(error: error)
        }
    }
    
    // MARK: Actions
    
    @IBAction func playbackPressed() {
        player.setIsPlaying(!player.playbackState.isPlaying, callback: nil)
    }
    
    @IBAction func rewindPressed() {
        player.skipPrevious { _ in
            
        }
    }
    
    @IBAction func forwardPressed() {
        player.skipNext { _ in
            
        }
    }
    
    @IBAction func sliderMoved(_ sender: UISlider) {
        guard let currentTrack = player.metadata.currentTrack else {
            return
        }
        isChangingProgress = false
        let time = currentTrack.duration * Double(sender.value)
        player.seek(to: time) { error in
            
        }
    }
    
}

// MARK: SPTAudioStreamingDelegate methods
extension PlayerViewController: SPTAudioStreamingDelegate {
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceiveMessage message: String) {
        let alertMessage = Message(title: "Message from Spotify", message: message)
        displayMessage(alertMessage)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceiveError error: Error) {
        let nsError = error as NSError
        
        print("*** Received error: (\(nsError.code))\(nsError.localizedDescription)")
        if nsError.code == SPTErrorCodeNeedsPremium {
            displayMessage(Message(title: "Premium account required", message: "Premium account is required to showcase application functionality. Please login using premium account.")) {
                self.closeSession()
            }
        }
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController) {
        
        player.playSpotifyURI("spotify:track:6K4t31amVTZDgR3sKmwUJJ", startingWith: 0, startingWithPosition: 0) { error in
            if let error = error {
                print("*** Failed to play: \(error.localizedDescription)")
            }
        }
    }
    
    func audioStreamingDidLogout(_ audioStreaming: SPTAudioStreamingController) {
        closeSession()
    }
}

// MARK: SPTAudioStreamingPlaybackDelegate methods
extension PlayerViewController: SPTAudioStreamingPlaybackDelegate {
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePlaybackStatus isPlaying: Bool) {
        print("is playing: \(isPlaying)")
        isPlaying ? activateAudioSession() : deactivateAudioSession()
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChange metadata: SPTPlaybackMetadata) {
        updateUI()
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceive event: SpPlaybackEvent) {
        print("didReceivePlaybackEvent: \(event.rawValue)")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePosition position: TimeInterval) {
        guard !isChangingProgress, let currentTrack = player.metadata.currentTrack else {
            progressSlider.value = 0
            return
        }
        progressSlider.value = Float(position / currentTrack.duration)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didStartPlayingTrack trackUri: String) {
        print("Started playing: \(trackUri)")
        print("Source \(player.metadata.currentTrack?.playbackSourceUri ?? "unknown")")
        // If context is a single track and the uri of the actual track being played is different
        // than we can assume that relink has happended.
        let isRelinked = player.metadata.currentTrack?.playbackSourceUri.contains("spotify:track") ?? false && player.metadata.currentTrack?.playbackSourceUri != trackUri
        print("Relinked: \(isRelinked)")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didStopPlayingTrack trackUri: String) {
        print("Finished playing: \(trackUri)")
    }
}

// MARK: Audio Session
extension PlayerViewController {
    func activateAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch let error {
            print("*** Failed to activate audio session: \(error.localizedDescription)")
        }
    }
    
    func deactivateAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        } catch let error {
            print("*** Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }
}
