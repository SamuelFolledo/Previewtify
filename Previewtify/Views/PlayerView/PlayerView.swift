//
//  PlayerView.swift
//  Previewtify
//
//  Created by Samuel Folledo on 10/7/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit
import Spartan
import AVFoundation

class PlayerView: UIView {
    
    //MARK: Properties
    var track: Track? {
        didSet { populateViews() }
    }
    var timer: Timer?
    var favoriteDelegate: SpotifyFavoriteTrackProtocol?
    var playDelegate: SpotifyPlayerProtocol?
    
    //MARK: Player
    var player: MusicPlayer?
    
    //MARK: IBOutlet Views
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var trackNameLabel: UILabel!
    @IBOutlet var artistNameLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var timeLeftLabel: UILabel!
    @IBOutlet weak var timerSlider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    
    //MARK: Initializers
    
    required init(track: Track?) {
        self.track = track
        super.init(frame: .zero)
        commonInit()
        setupViews()
        populateViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        timer?.invalidate()
    }
    
    //MARK: Methods
    
    fileprivate func commonInit() {
        Bundle.main.loadNibNamed("PlayerView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    fileprivate func setupViews() {
        containerView.backgroundColor = .secondaryLabel
        //slider
        timerSlider.tintColor = .previewtifyGreen
        timerSlider.addTarget(self, action: #selector(self.updateTimerSlider), for: .valueChanged)
        //Labels
        [trackNameLabel, artistNameLabel, timeLabel, timeLeftLabel].forEach {
            $0?.textColor = .systemBackground
        }
        //Buttons
        let heartImage = Constants.Images.heart.withRenderingMode(.alwaysTemplate).withTintColor(.systemBackground)
        favoriteButton.setImage(heartImage, for: .normal)
        let heartFilledImage = Constants.Images.heartFilled.withRenderingMode(.alwaysOriginal)
        favoriteButton.setImage(heartFilledImage, for: .selected)
        favoriteButton.tintColor = .systemBackground
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        
        let playImage = Constants.Images.play.withRenderingMode(.alwaysTemplate)
        playButton.setImage(playImage, for: .normal)
        let pauseImage = Constants.Images.pause.withRenderingMode(.alwaysTemplate)
        playButton.setImage(pauseImage, for: .selected)
        playButton.tintColor = .systemBackground
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        playButton.imageView?.contentMode = .scaleAspectFit
        
        let backwardImage = Constants.Images.skipBack15.withRenderingMode(.alwaysTemplate)
        backButton.setImage(backwardImage, for: .normal)
        backButton.tintColor = .systemBackground
        backButton.addTarget(self, action: #selector(skipBackwardButtonTapped), for: .touchUpInside)
        
        let forwardImage = Constants.Images.skipForward15.withRenderingMode(.alwaysTemplate)
        forwardButton.setImage(forwardImage, for: .normal)
        forwardButton.tintColor = .systemBackground
        forwardButton.addTarget(self, action: #selector(skipForwardButtonTapped), for: .touchUpInside)
        
    }
    
    func populateViews() {
        trackNameLabel.text = "\(track?.name ?? "No Track Name")"
        artistNameLabel.text = "\(track?.artists.first?.name ?? "No Artist")"
    }
    
    func playTrackFrom(urlString: String) {
        if let player = player { //if we already have a player
            player.initPlayer(url: urlString)
        } else { //create new player
            let musicPlayer = MusicPlayer()
            player = musicPlayer
            player?.initPlayer(url: urlString)
        }
        setupTimerViews()
    }
    
    func setupTimerViews() {
        DispatchQueue.main.async {
            guard let player = self.player else { return }
            player.play()
            self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.updateTrackTime), userInfo: nil, repeats: true)
        }
    }
    
    func configurePlayerView(hasPreviewUrl: Bool) {
        if hasPreviewUrl {
            timerSlider.isHidden = false
            timeLabel.isHidden = false
            timeLeftLabel.isHidden = false
        } else {
            timerSlider.isHidden = true
            timeLabel.isHidden = true
            timeLeftLabel.isHidden = true
        }
    }
    
    //MARK: Timer
    
    @objc func updateTrackTime() {
        guard let player = player,
              let item = player.player.currentItem,
              item.status == .readyToPlay //make sure item is ready to play
        else { return }
        let times = player.currentTime()
        //update slider
        timerSlider.maximumValue = Float(times.duration)
        timerSlider.value = Float(times.current)
//        Update time labels
        timeLabel.text = "\(times.current.asFormattedString())"
        let remainingTimeInSeconds = times.duration - times.current
        timeLeftLabel.text = "\(remainingTimeInSeconds.asFormattedString())"
    }
    
    //MARK: Target Methods
    
    ///updates song timer when slider is changed
    @objc func updateTimerSlider() {
        guard let player = player else { return }
        let seconds: Int64 = Int64(timerSlider.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        player.player.seek(to: targetTime)
        if player.player.rate == 0 {
            player.play()
        }
    }
    
    @objc func playButtonTapped() {
        if playButton.isSelected { //if playing
            playButton.isSelected = false
            if let _ = track?.previewUrl { //we have previewUrl
                playDelegate?.playTrack(track: track!, shouldPlay: false)
                return
            } else if let openUrl = track?.externalUrls.first?.value { //we dont have previewUrl
                playDelegate?.openTrack(track: track!, openUrl: openUrl, shouldOpen: false)
            }
        } else { //if paused
            playButton.isSelected = true
            if let _ = track?.previewUrl { //we have previewUrl
                playDelegate?.playTrack(track: track!, shouldPlay: true)
                return
            } else if let openUrl = track?.externalUrls.first?.value { //we dont have previewUrl
                playDelegate?.openTrack(track: track!, openUrl: openUrl, shouldOpen: true)
            }
        }
    }
    
    @objc func favoriteButtonTapped() {
        guard let track = track else { return }
        if favoriteButton.isSelected == true {
            //unfavorite
            favoriteDelegate?.favoriteTrack(track: track, shouldFavorite: true)
            favoriteButton.isSelected = true
        } else {
            favoriteDelegate?.favoriteTrack(track: track, shouldFavorite: false)
            favoriteButton.isSelected = false
        }
    }
    
    ///forward song by 15 seconds max
    @objc func skipForwardButtonTapped() {
        guard let player = player else { return }
        let seekDuration: Float64 = 15
        if let duration = player.player.currentItem?.duration { //get the current song's duration
            let playerCurrentTime = CMTimeGetSeconds(player.player.currentTime())
            let newTime = playerCurrentTime + seekDuration
            if newTime < CMTimeGetSeconds(duration) { //dont forward song if if it less than the seekDuration
                let selectedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
                player.player.seek(to: selectedTime)
            }
            player.pause()
            playButton.isSelected = true
            player.play()
        }
    }
    
    ///make player go backward
    @objc func skipBackwardButtonTapped() {
        guard let player = player else { return }
        let seekDuration: Float64 = 15
        let playerCurrenTime = CMTimeGetSeconds(player.player.currentTime())
        var newTime = playerCurrenTime - seekDuration
        if newTime < 0 { newTime = 0 } //set time to 0 if less than 0
        player.pause()
        let selectedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        player.player.seek(to: selectedTime)
        playButton.isSelected = true
        player.play()
    }
}
