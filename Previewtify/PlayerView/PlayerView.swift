//
//  PlayerView.swift
//  Previewtify
//
//  Created by Samuel Folledo on 10/7/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit
import Spartan

class PlayerView: UIView {
    
    //MARK: Properties
    
    var track: Track?
    
    //MARK: Views
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var trackNameLabel: UILabel!
    @IBOutlet var artistNameLabel: UILabel!
    @IBOutlet var currentTimeLabel: UILabel!
    @IBOutlet var endTimeLabel: UILabel!
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
        trackNameLabel.text = "\(track?.name ?? "")"
        artistNameLabel.text = "\(track?.artists.first?.name ?? "")"
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
        contentView.backgroundColor = .label
        [trackNameLabel, artistNameLabel, currentTimeLabel, endTimeLabel].forEach {
            $0?.textColor = .systemBackground
        }
        
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
    
    @objc func playButtonTapped() {
        playButton.isSelected = !playButton.isSelected
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
