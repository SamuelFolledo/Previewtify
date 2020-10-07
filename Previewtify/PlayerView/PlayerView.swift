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
    
    //MARK: View Properties
//    lazy var containerView: UIView = {
//        let view: UIView = UIView(frame: .zero)
//        view.layer.masksToBounds = true
//        view.layer.cornerRadius = 10
//        view.layer.borderColor = UIColor.clear.cgColor
//        view.layer.borderWidth = 2
//        return view
//    }()
//
//    lazy var mainStackView: UIStackView = { //will contain colorView and verticalStackView
//        let stackView: UIStackView = UIStackView()
//        stackView.axis = .horizontal
//        stackView.alignment = .center
//        stackView.distribution = .fillProportionally
//        stackView.spacing = 10
//        return stackView
//    }()
//    lazy var artistImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.clipsToBounds = false
//        imageView.contentMode = .scaleAspectFill
//        imageView.layer.cornerRadius = 5
//        return imageView
//    }()
//    lazy var verticalStackView: UIStackView = { //will contain the nameLabel, detailLabel, and pendingTaskLabel
//        let stackView: UIStackView = UIStackView()
//        stackView.axis = .vertical
//        stackView.alignment = .leading
//        stackView.distribution = .fillProportionally
//        stackView.spacing = 5
//        return stackView
//    }()
//    lazy var nameLabel: UILabel = {
//        let label: UILabel = UILabel()
//        label.font = .font(size: 18, weight: .semibold, design: .default)
//        label.textColor = .label
//        label.numberOfLines = 2
//        label.textAlignment = .left
//        return label
//    }()
//    lazy var detailLabel: UILabel = {
//        let label: UILabel = UILabel()
//        label.font = .font(size: 14, weight: .regular, design: .rounded)
//        label.textColor = .secondaryLabel
//        label.numberOfLines = 1
//        label.textAlignment = .left
//        return label
//    }()
//    lazy var rankLabel: UILabel = {
//        let label: UILabel = UILabel()
//        label.font = .font(size: 18, weight: .regular, design: .rounded)
//        label.textColor = .label
//        label.numberOfLines = 1
//        label.textAlignment = .left
//        return label
//    }()
//    lazy var playButton: UIButton = {
//        let button = UIButton()
//        button.setImage(Constants.Images.play, for: .normal)
//        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
//        button.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
//        button.clipsToBounds = true
//        button.layer.cornerRadius = 30
//        button.layer.masksToBounds = false
////        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
//        return button
//    }()
//
//    lazy var favoriteButton: UIButton = {
//        let button = UIButton()
//        button.setImage(Constants.Images.heart, for: .normal)
//        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
//        button.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
//        button.clipsToBounds = true
//        button.layer.cornerRadius = 30
//        button.layer.masksToBounds = false
////        button.addTarget(self, action: #selector(handleFavorite), for: .touchUpInside)
//        return button
//    }()
    
    //MARK: Initializers
    required init(track: Track?) {
        trackNameLabel.text = "\(track?.name ?? "")"
        artistNameLabel.text = "\(track?.artists.first?.name ?? "")"
        self.track = track
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Methods
    
    fileprivate func commonInit() {
        Bundle.main.loadNibNamed("NavigationBarView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
