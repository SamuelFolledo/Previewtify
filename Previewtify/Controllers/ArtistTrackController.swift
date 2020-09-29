//
//  ArtistTrackController.swift
//  Previewtify
//
//  Created by Samuel Folledo on 9/29/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit
import Spartan

class ArtistTrackController: UIViewController {
    
    //MARK: Properties
    var artist: Artist!
    var tracks: [Track] = [] {
        didSet { tableView.reloadData() }
    }
    
    //MARK: Views
    //MARK: Views
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: .zero, style: .grouped)
        table.sectionHeaderHeight = 40
        table.backgroundColor = .systemBackground
        table.rowHeight = 100
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.tableFooterView = UIView()
        table.allowsMultipleSelection = false
        table.register(TrackCell.self, forCellReuseIdentifier: String(describing: TrackCell.self))
        return table
    }()
    
    //MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
//        guard let artistId = artist.id as? String else { return }
//        Spartan.getArtistsTopTracks(artistId: artistId, country: .us) { (tracks) in
//            self.tracks = tracks
//        } failure: { (error) in
//            self.presentAlert(title: "Error Fetching Tracks", message: error.localizedDescription)
//        }
        fetchTracks()
    }
    //MARK: Private Methods
    
    fileprivate func setupViews() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        setupBackground()
    }
    
    fileprivate func setupBackground() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Top 50 Artists"
        view.backgroundColor = .systemBackground
    }
    
    func fetchTracks() {
        guard let artistId = artist.id as? String else { return }
        Spartan.getArtistsTopTracks(artistId: artistId, country: .us) { (tracks) in
            self.tracks = tracks
        } failure: { (error) in
            self.presentAlert(title: "Error Fetching Tracks", message: error.localizedDescription)
        }
    }
    
    //MARK: Helpers
}

//MARK: Extensions

extension ArtistTrackController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let cell = collectionView.cellForItem(at: indexPath) as! ArtistCell
        let track = tracks[indexPath.row]
        let vc = ArtistTrackController()
//        vc.artist = artist
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ArtistTrackController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TrackCell.self), for: indexPath) as! TrackCell
        DispatchQueue.global(qos: .userInteractive).async {
            let track = self.tracks[indexPath.row]
            DispatchQueue.main.async {
                cell.track = track
                cell.layoutSubviews()
            }
        }
        return cell
    }
}
