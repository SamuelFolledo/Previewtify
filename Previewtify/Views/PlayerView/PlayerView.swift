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
        let heartImage = Constants.Images.heart.withRenderingMode(.alwaysTemplate)
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
        
        let backwardImage = Constants.Images.skipBack15.withRenderingMode(.alwaysTemplate)
        backButton.setImage(backwardImage, for: .normal)
        backButton.tintColor = .systemBackground
        backButton.addTarget(self, action: #selector(skipBackwardButtonTapped), for: .touchUpInside)
        
        let forwardImage = Constants.Images.skipForward15.withRenderingMode(.alwaysTemplate)
        forwardButton.setImage(forwardImage, for: .normal)
        forwardButton.tintColor = .systemBackground
        forwardButton.addTarget(self, action: #selector(skipForwardButtonTapped), for: .touchUpInside)
        
    }
    
    func playTrackFrom(urlString: String) {
        if let player = player { //if we already have a player
            player.initPlayer(url: urlString)
            player.play()
        } else { //create new player
            let musicPlayer = MusicPlayer()
            player = musicPlayer
            player?.initPlayer(url: urlString)
            player?.play()
        }
//        musicPlayer.playAudioBackground()
//        MusicPlayer.initPlayer(url: urlString)
//        guard  let url = URL(string: urlString) else { return }
//        let downloadTask = URLSession.shared.downloadTask(with: url) { (url, response, error) in
//            if let error = error {
//                print("Error downloading tasks \(error.localizedDescription)")
//                return
//            }
//            do {
//                self.player = try AVAudioPlayer(contentsOf: url!)
//                self.player?.prepareToPlay()
//                self.player?.volume = 1
////                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
////                try AVAudioSession.sharedInstance().setActive(true)
////                player = try AVPlayer(url: url as URL)
////                guard let player = player else { return }
//                self.player?.play()
//            } catch let error {
//                print(error.localizedDescription)
//            }
//        }
//        downloadTask.resume()
    }
    
    func setupTimerSlider() {
        guard let player = player else { return }
        timerSlider.value = 0.0
//        timerSlider.maximumValue = Float(player.duration)
//        player.play()
        timer = Timer.scheduledTimer(timeInterval: 0.0001, target: self, selector: #selector(self.updateTrackTime), userInfo: nil, repeats: true)
    }
    
    func populateViews() {
        trackNameLabel.text = "\(track?.name ?? "No Track Name")"
        artistNameLabel.text = "\(track?.artists.first?.name ?? "No Artist")"
    }
    
    //MARK: Timer
    
    @objc func updateTrackTime() {
        guard let player = player else { return }
//        timerSlider.value = Float(player.currentTime)
        //Update time labels
//        timeLabel.text = "\(player.currentTime.asFormattedString())"
//        let remainingTimeInSeconds = player.duration - player.currentTime
//        timeLeftLabel.text = "\(remainingTimeInSeconds.asFormattedString())"
    }
    
    //MARK: Target Methods
    
    @objc func updateTimerSlider() {
        guard let player = player else { return }
//        player.currentTime = Float64(timerSlider.value)
    }
    
    @objc func playButtonTapped() {
        guard let player = player else { return }
        if playButton.isSelected { //if playing
            playButton.isSelected = false
            player.pause()
        } else { //if paused
            playButton.isSelected = true
            player.play()
        }
    }
    
    @objc func favoriteButtonTapped() {
        favoriteButton.isSelected = !favoriteButton.isSelected
    }
    
    @objc func skipForwardButtonTapped() {
        print("Go Forward 15 seconds")
    }
    
    @objc func skipBackwardButtonTapped() {
        print("Go back 15 seconds")
    }
}
