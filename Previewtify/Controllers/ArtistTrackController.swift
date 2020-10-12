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
    var tracks: [Track] = []
    
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
    
    //MARK: Spotify Properties
    var defaultCallback: SPTAppRemoteCallback {
        get {
            return {[weak self] _, error in
                if let error = error {
                    self?.presentAlert(title: "Spotify Error", message: error.localizedDescription)
                }
            }
        }
    }
    var appRemote: SPTAppRemote? {
        get { return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appRemote }
    }
//    lazy var sessionManager: SPTSessionManager? = {
//        let sessionManager = SPTSessionManager(configuration: NetworkManager.configuration, delegate: self)
//        return sessionManager
//    }()
    
    //MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appRemote?.connectionParameters.accessToken = SpotifyAuth.current?.accessToken
        appRemote?.connect()
        if appRemote?.isConnected == true {
            print("App remote Connected")
        }
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
        view.backgroundColor = .systemBackground
        guard let artistName = artist.name else { return }
        title = "\(artistName)'s Top Tracks"
    }
    
    func fetchTracks() {
        guard let artistId = artist.id as? String else { return }
        NetworkManager.getArtistTopTracks(artistId: artistId) { (result) in
            switch result {
            case .failure(let error):
                self.presentAlert(title: "Error Fetching Tracks", message: error.localizedDescription)
            case .success(let tracks):
                self.tracks = tracks
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: Helpers
}

//MARK: Extensions

extension ArtistTrackController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let cell = collectionView.cellForItem(at: indexPath) as! ArtistCell
        let track = tracks[indexPath.row]
        print(track.name!)
    }
}

extension ArtistTrackController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TrackCell.self), for: indexPath) as! TrackCell
        let tabBarController = self.tabBarController as! TabBarController
        cell.playerDelegate = tabBarController
        cell.favoriteDelegate = tabBarController
        DispatchQueue.global(qos: .userInteractive).async {
            let track = self.tracks[indexPath.row]
            NetworkManager.checkIfFavorite(trackId: track.id as! String) { (isFavorite) in
                DispatchQueue.main.async {
                    let image = isFavorite ? Constants.Images.heartFilled : Constants.Images.heart
                    cell.favoriteButton.setImage(image, for: .normal)
                    cell.populateViews(track: track, rank: indexPath.row + 1)
                    cell.layoutSubviews()
                }
            }
        }
        return cell
    }
}
