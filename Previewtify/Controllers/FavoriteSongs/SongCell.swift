////
////  SongCell.swift
////  Previewtify
////
////  Created by Samuel Folledo on 9/29/20.
////  Copyright © 2020 SamuelFolledo. All rights reserved.
////
//
//import UIKit
//import Spartan
//
//class SongCell: UITableViewCell {
//    
//    //MARK: Properties
//    var track: Track! {
//        didSet { populateViews() }
//    }
//    
//    //MARK: View Properties
//    lazy var containerView: UIView = {
//        let view: UIView = UIView(frame: .zero)
////        view.backgroundColor = .systemGray6
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
////    lazy var verticalStackView: UIStackView = { //will contain the nameLabel, detailLabel, and pendingTaskLabel
////        let stackView: UIStackView = UIStackView()
////        stackView.axis = .vertical
////        stackView.alignment = .leading
////        stackView.distribution = .fill
////        stackView.spacing = 5
////        return stackView
////    }()
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
//        label.isHidden = true
//        return label
//    }()
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
//        setupViews()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        nameLabel.text = ""
//        detailLabel.text = ""
//        detailLabel.isHidden = true
//        artistImageView.image = nil
//    }
//    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
////        containerView.layer.borderColor = isSelected ? project.color!.cgColor : UIColor.clear.cgColor //apply border colors
//    }
//    
//    //MARK: Private Methods
//    func setupViews() {
//        selectionStyle = .none
//        contentView.backgroundColor = .clear
//        contentView.addSubview(containerView)
//        containerView.snp.makeConstraints {
//            $0.top.equalToSuperview().offset(10)
//            $0.leading.equalToSuperview()
//            $0.trailing.equalToSuperview()
//            $0.bottom.equalToSuperview().offset(-10)
//        }
//        //setup mainStackView
//        containerView.addSubview(mainStackView)
//        mainStackView.snp.makeConstraints {
//            $0.top.equalToSuperview().offset(10)
//            $0.leading.equalToSuperview().offset(20)
//            $0.trailing.equalToSuperview().offset(-20)
//            $0.bottom.equalToSuperview().offset(-10)
//        }
//        mainStackView.addArrangedSubview(artistImageView)
//        artistImageView.snp.makeConstraints {
//            $0.height.width.equalTo(containerView.snp.height).multipliedBy(0.8)
//        }
//        mainStackView.addArrangedSubview(nameLabel)
//        nameLabel.snp.makeConstraints {
//            $0.height.equalTo(30)
//        }
////        mainStackView.addArrangedSubview(colorView)
////        colorView.snp.makeConstraints { (make) in
////            $0.height.equalTo(40)
////            $0.width.equalTo(40)
////            $0.centerY.equalToSuperview()
////        }
////        mainStackView.addArrangedSubview(verticalStackView)
////        verticalStackView.snp.makeConstraints { (make) in
////            $0.height.equalToSuperview()
////            $0.width.lessThanOrEqualToSuperview()
////        }
////        verticalStackView.addArrangedSubview(nameLabel)
////        nameLabel.snp.makeConstraints { (make) in
////            $0.width.equalToSuperview()
////        }
////        verticalStackView.addArrangedSubview(detailLabel)
////        detailLabel.snp.makeConstraints { (make) in
////            $0.width.equalToSuperview()
////        }
////        verticalStackView.addArrangedSubview(pendingTaskLabel)
////        pendingTaskLabel.snp.makeConstraints { (make) in
////            $0.width.equalToSuperview()
////        }
//    }
//    
//    fileprivate func populateViews() {
//        nameLabel.text = track.name
//        detailLabel.text = track.album.name
//        guard let urlString = track.album.images.first?.url,
//              let imageUrl = URL(string: urlString)
//        else { return }
//        artistImageView.kf.setImage(with: imageUrl, placeholder: nil, options: nil) { (receivedSize, totalSize) in
//            
//        } completionHandler: { (result) in
//            //            self.imgIndicator.shouldAnimate(shouldAnimate: false)
//            do {
//                let _ = try result.get() //value
//            } catch {
//                DispatchQueue.main.async {
//                    print("Done downloading image")
//                }
//            }
//        }
//    }
//}
