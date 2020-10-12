//
//  FavoriteSongController.swift
//  Previewtify
//
//  Created by Samuel Folledo on 9/29/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit
import Spartan

class FavoriteSongController: UIViewController {
    
    //MARK: Properties
    var artist: Artist!
    var trackIds: [String] = []
    var offset: Int = 0
    var spartanCallbackError: (Error?) -> () {
        get {
            return {[weak self] error in
                if let error = error {
                    self?.presentAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    weak var customTabBarController: TabBarController!
    
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFavoriteSongs()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        offset = 0
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
        navigationController?.navigationBar.topItem?.title = "Favorite Songs"
        view.backgroundColor = .systemBackground
    }
    
    func fetchFavoriteSongs() {
        customTabBarController.fetchFavoriteSongs(offset: offset) {
            self.offset = self.customTabBarController.savedTracks.count - 1
            self.tableView.reloadData()
        }
    }
    
    //MARK: Helpers
}

//MARK: Extensions

extension FavoriteSongController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath) as! ArtistCell
//        let track = tracks[indexPath.row]
//        let vc = ArtistTrackController()
//        vc.artist = artist
//        navigationController?.pushViewController(vc, animated: true)
    }
}

extension FavoriteSongController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        customTabBarController.savedTracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TrackCell.self), for: indexPath) as? TrackCell,
              let tabBarController = self.tabBarController as? TabBarController
        else { return UITableViewCell() }
        cell.favoriteButton.setImage(Constants.Images.heartFilled, for: .normal)
        cell.playerDelegate = tabBarController
        cell.favoriteDelegate = self
        let track = customTabBarController.savedTracks[indexPath.row]
        DispatchQueue.global(qos: .userInteractive).async {
            DispatchQueue.main.async {
                cell.populateViews(track: track.track, rank: indexPath.row + 1)
                cell.detailLabel.text = track.track.artists.first?.name ?? "No artist"
                cell.layoutSubviews()
            }
        }
        return cell
    }
}

extension FavoriteSongController: SpotifyFavoriteTrackProtocol {
    func favoriteTrack(track: Track, shouldFavorite: Bool) {
        guard let trackId = track.id as? String else { return }
        if shouldFavorite {
            Spartan.saveTracks(trackIds: [trackId], success: nil, failure: spartanCallbackError)
        } else {
            Spartan.removeSavedTracks(trackIds: [trackId], success: nil, failure: spartanCallbackError)
            let trackRow = customTabBarController.savedTracks.firstIndex { $0.track.id as? String == trackId }
            if trackRow != nil {
                customTabBarController.savedTracks.remove(at: trackRow!)
                let indexPath = IndexPath(row: trackRow!, section: 0)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
}
