//
//  TrackCell.swift
//  Previewtify
//
//  Created by Samuel Folledo on 9/29/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit
import Spartan

protocol SpotifyPlayerProtocol {
    func playTrack(track: Track, shouldPlay: Bool)
    func openTrack(track: Track, openUrl: String, shouldOpen: Bool)
}

protocol SpotifyFavoriteTrackProtocol {
    func favoriteTrack(track: Track, shouldFavorite: Bool)
}

class TrackCell: UITableViewCell {
    
    //MARK: Properties
    var track: Track!
    var trackId: String!
    var playerDelegate: SpotifyPlayerProtocol?
    var favoriteDelegate: SpotifyFavoriteTrackProtocol?
    var trackOpenUrl: String?
    
    //MARK: View Properties
    lazy var containerView: UIView = {
        let view: UIView = UIView(frame: .zero)
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
        view.layer.borderColor = UIColor.clear.cgColor
        view.layer.borderWidth = 2
        return view
    }()
    
    lazy var mainStackView: UIStackView = { //will contain colorView and verticalStackView
        let stackView: UIStackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        return stackView
    }()
    lazy var artistImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        return imageView
    }()
    lazy var verticalStackView: UIStackView = { //will contain the nameLabel, detailLabel, and pendingTaskLabel
        let stackView: UIStackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        stackView.spacing = 5
        return stackView
    }()
    lazy var nameLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = .font(size: 18, weight: .semibold, design: .default)
        label.textColor = .label
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    lazy var detailLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = .font(size: 14, weight: .regular, design: .rounded)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    lazy var rankLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = .font(size: 18, weight: .regular, design: .rounded)
        label.textColor = .label
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    lazy var playButton: UIButton = {
        let button = UIButton()
        button.setImage(Constants.Images.play, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        button.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        button.clipsToBounds = true
        button.layer.cornerRadius = 30
        button.layer.masksToBounds = false
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    lazy var favoriteButton: UIButton = {
        let button = UIButton()
        button.setImage(Constants.Images.heart, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        button.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        button.clipsToBounds = true
        button.layer.cornerRadius = 30
        button.layer.masksToBounds = false
        button.addTarget(self, action: #selector(handleFavorite), for: .touchUpInside)
        return button
    }()
    
    //MARK: Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Override
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = ""
        detailLabel.text = ""
        rankLabel.text = ""
        artistImageView.image = nil
        playButton.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
//        containerView.layer.borderColor = isSelected ? project.color!.cgColor : UIColor.clear.cgColor //apply border colors
    }
    
    //MARK: Private Methods
    
    func setupViews() {
        selectionStyle = .none
        contentView.backgroundColor = .clear
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-5)
        }
        //setup mainStackView
        containerView.addSubview(mainStackView)
        mainStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-5)
        }
        [rankLabel, artistImageView, verticalStackView, playButton, favoriteButton].forEach {
            mainStackView.addArrangedSubview($0)
        }
        rankLabel.snp.makeConstraints {
            $0.width.height.equalTo(25)
        }
        artistImageView.snp.makeConstraints {
            $0.height.width.equalTo(containerView.snp.height).multipliedBy(0.8)
        }
        //vertical stack view
        verticalStackView.snp.makeConstraints {
            $0.height.equalToSuperview()
        }
        verticalStackView.addArrangedSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.width.equalToSuperview()
        }
        verticalStackView.addArrangedSubview(detailLabel)
        detailLabel.snp.makeConstraints {
            $0.width.equalToSuperview()
        }
        //buttons
        [playButton, favoriteButton].forEach {
            $0.snp.makeConstraints {
                $0.width.height.equalTo(35)
            }
        }
    }
    
    func populateViews(track: Track, rank: Int) {
        self.track = track
        rankLabel.text = "\(rank)"
        nameLabel.text = track.name
        detailLabel.text = track.album?.name ?? "No album"
        if track.previewUrl != nil { //if there's a preview url
            playButton.setImage(Constants.Images.play, for: .normal)
            playButton.isHidden = false
        } else if let urlDic = track.externalUrls.first {
            playButton.setImage(Constants.Images.spotifyIcon, for: .normal)
            print("GOT URL DIC \(urlDic)")
            trackOpenUrl = urlDic.value
        } else {
            playButton.isHidden = true
        }
        guard let urlString = track.album?.images.first?.url,
              let imageUrl = URL(string: urlString)
        else { return }
        artistImageView.kf.setImage(with: imageUrl, placeholder: nil, options: nil) { (receivedSize, totalSize) in
            
        } completionHandler: { (result) in
            //            self.imgIndicator.shouldAnimate(shouldAnimate: false)
            do {
                let _ = try result.get() //value
            } catch {
                DispatchQueue.main.async {
                    print("Done downloading image")
                }
            }
        }
    }
    
    //MARK: Helpers
    
    @objc func handlePlay() {
        if let url = trackOpenUrl { //no preview Url, but we have an openUrl
            if playButton.currentImage == Constants.Images.spotifyIcon {
                playButton.setImage(Constants.Images.pause, for: .normal)
                playerDelegate?.openTrack(track: track, openUrl: url, shouldOpen: true)
            } else {
                playButton.setImage(Constants.Images.spotifyIcon, for: .normal)
                playerDelegate?.openTrack(track: track, openUrl: url, shouldOpen: false)
            }
        } else {
            if playButton.currentImage == Constants.Images.play {
                playButton.setImage(Constants.Images.pause, for: .normal)
                playerDelegate?.playTrack(track: track, shouldPlay: true)
            } else {
                playButton.setImage(Constants.Images.play, for: .normal)
                playerDelegate?.playTrack(track: track, shouldPlay: false)
            }
        }
    }
    
    @objc func handleFavorite() {
        if favoriteButton.currentImage == Constants.Images.heart {
            favoriteButton.setImage(Constants.Images.heartFilled, for: .normal)
            favoriteDelegate?.favoriteTrack(track: track, shouldFavorite: true)
        } else {
            favoriteButton.setImage(Constants.Images.heart, for: .normal)
            favoriteDelegate?.favoriteTrack(track: track, shouldFavorite: false)
        }
    }
}
