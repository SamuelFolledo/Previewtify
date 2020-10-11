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
    private var lastPlayerState: SPTAppRemotePlayerState?
    
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

////MARK: Spotify Player Protocol
//extension ArtistTrackController: SpotifyPlayerProtocol {
//    func playTrack(track: Track, shouldPlay: Bool) {
//        print("\n\n\(shouldPlay ? "Playing" : "Paused") Track \(track.name!) at \(track.uri!) AND \(track.href!)\n\n")
//        let tabBarController = self.tabBarController as! TabBarController
//        if shouldPlay {
//            tabBarController.playerView.track = track
//        } else {
//            tabBarController.playerView.playButton.isSelected = false
//        }
//        tabBarController.playerViewIsHidden = !shouldPlay
//        appRemote?.playerAPI?.play(track.uri, callback: defaultCallback)
////        let playURI = "spotify:album:1htHMnxonxmyHdKE2uDFMR"
////        if let lastPlayerState = lastPlayerState, lastPlayerState.isPaused {
////            appRemote.playerAPI?.resume(nil)
////        } else {
////            appRemote.playerAPI?.pause(nil)
////        }
//        if appRemote?.isConnected == true{
//            if shouldPlay {
//                appRemote?.playerAPI?.play(track.uri, callback: defaultCallback)
//            } else {
//                pausePlayback()
//            }
//
////            if lastPlayerState == nil || lastPlayerState!.isPaused {
////                startPlayback()
////            } else {
////                pausePlayback()
////            }
//        } else { //if app remote is not connected
//            if appRemote?.authorizeAndPlayURI(track.uri) == false { //// The Spotify app is not installed, present the user with an App Store page https://spotify.github.io/ios-sdk/html/Classes/SPTAppRemote.html#//api/name/connect
////                showAppStoreInstall()
//                print("Spotify App not installed")
//            } else {
//                appRemote?.connectionParameters.accessToken = SpotifyAuth.current?.accessToken
//                appRemote?.connect()
//            }
//        }
//    }
//
//    func favoriteTrack(track: Track, shouldFavorite: Bool) {
//        print("Track \(track.name!) will favorite \(shouldFavorite)")
//        trackIds.append(track.id as! String)
//    }
//}

//MARK: Spotify Methods
extension ArtistTrackController {
    private func startPlayback() {
        appRemote?.playerAPI?.resume(defaultCallback)
    }

    private func pausePlayback() {
        appRemote?.playerAPI?.pause(defaultCallback)
    }
    
    private func playTrack() {
        print("Playing track!!!")
//        appRemote.playerAPI?.play(trackIdentifier, callback: defaultCallback)
    }
    
    func update(playerState: SPTAppRemotePlayerState) {
        if lastPlayerState?.track.uri != playerState.track.uri {
//            fetchArtwork(for: playerState.track)
        }
        lastPlayerState = playerState
//        trackLabel.text = playerState.track.name
        if playerState.isPaused {
//            pauseAndPlayButton.setImage(UIImage(named: "playButton"), for: .normal)
        } else {
//            pauseAndPlayButton.setImage(UIImage(named: "pauseButton"), for: .normal)
        }
    }

    func updateViewBasedOnConnected() {
        if appRemote?.isConnected == true {
//            connectButton.isHidden = true
//            disconnectButton.isHidden = false
//            connectLabel.isHidden = true
//            imageView.isHidden = false
//            trackLabel.isHidden = false
//            pauseAndPlayButton.isHidden = false
        } else { //show login
//            disconnectButton.isHidden = true
//            connectButton.isHidden = false
//            connectLabel.isHidden = false
//            imageView.isHidden = true
//            trackLabel.isHidden = true
//            pauseAndPlayButton.isHidden = true
        }
    }
    
    func fetchPlayerState() {
        appRemote?.playerAPI?.getPlayerState({ [weak self] (playerState, error) in
            if let error = error {
                print("Error getting player state:" + error.localizedDescription)
            } else if let playerState = playerState as? SPTAppRemotePlayerState {
                self?.update(playerState: playerState)
            }
        })
    }
}

// MARK: - SPTAppRemoteDelegate
extension ArtistTrackController: SPTAppRemoteDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
//        self.appRemote.playerAPI?.pause(nil)
//        self.appRemote.disconnect()
        updateViewBasedOnConnected()
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe(toPlayerState: { (success, error) in
            if let error = error {
                print("Error subscribing to player state:" + error.localizedDescription)
            }
        })
        fetchPlayerState()
    }

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        updateViewBasedOnConnected()
        lastPlayerState = nil
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        updateViewBasedOnConnected()
        lastPlayerState = nil
    }
}

// MARK: - SPTAppRemotePlayerAPIDelegate
extension ArtistTrackController: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        debugPrint("\n\nSpotify Track name: %@", playerState.track.name)
        update(playerState: playerState)
    }
}
