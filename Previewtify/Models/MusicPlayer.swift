//
//  MusicPlayer.swift
//  Previewtify
//
//  Created by Samuel Folledo on 10/11/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import AVFoundation

class MusicPlayer {
    public static var instance = MusicPlayer()
    var player = AVPlayer()

    func initPlayer(url: String) {
        guard let url = URL(string: url) else { return }
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        playAudioBackground()
    }
    
    func playAudioBackground() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.mixWithOthers, .allowAirPlay])
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print(error)
        }
    }
    
    func pause() {
        player.pause()
    }
    
    func play() {
        player.play()
    }
}
