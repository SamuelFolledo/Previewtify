//
//  TabBarController.swift
//  Previewtify
//
//  Created by Samuel Folledo on 9/30/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import SnapKit
import SwipeableTabBarController
import AVFoundation
import Spartan

class TabBarController: SwipeableTabBarController {
    
    //MARK: Properties
    public var savedTracks: [SavedTrack] = []
    private var playerState: SPTAppRemotePlayerState?
    private var connectionIndicatorView = ConnectionStatusIndicatorView()
    private var subscribedToPlayerState: Bool = false
    private var subscribedToCapabilities: Bool = false
    
    var defaultCallback: SPTAppRemoteCallback {
        get {
            return {[weak self] _, error in
                if let error = error {
                    self?.displayError(error as NSError)
                }
            }
        }
    }
    var spartanCallbackError: (Error?) -> () {
        get {
            return {[weak self] error in
                if let error = error {
                    self?.presentAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    var appRemote: SPTAppRemote? {
        get { return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appRemote }
    }
    
    //MARK: View Properties
    
    var playerView: PlayerView = {
        let playerView = PlayerView(track: nil)
        return playerView
    }()
    
    var homeNavigationController: UINavigationController!
    var favoriteSongNavigationController: UINavigationController!
    
    //MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTabBar()
        addViewControllers()
        constraintPlayerView()
        //refresh access token and fetch favorite songs
        NetworkManager.refreshAcessToken { (result) in
            switch result {
            case .failure(let error):
                self.presentAlert(title: "Error Refreshing Token", message: error.localizedDescription)
            case .success(_):
                self.fetchFavoriteSongs(offset: 0) { }
            }
        }
    }
    
    //MARK: Methods
    func setUpTabBar() {
        tabBar.isTranslucent = false
        tabBar.barTintColor = .secondaryLabel
        tabBar.tintColor = .previewtifyGreen
        /// Set the animation type for swipe
        swipeAnimatedTransitioning?.animationType = SwipeAnimationType.sideBySide
        /// Set the animation type for tap
//        tapAnimatedTransitioning?.animationType = SwipeAnimationType.push
        /// if you want cycling switch tab, set true 'isCyclingEnabled'
//        isCyclingEnabled = true
        /// Disable custom transition on tap.
//        tapAnimatedTransitioning = nil
    }
    
    fileprivate func addViewControllers() {
        let homeController = HomeController()
        homeNavigationController = UINavigationController(rootViewController: homeController)
        homeNavigationController.tabBarItem = UITabBarItem(title: "Home",
                                                           image: UIImage(systemName: "house.fill"),
                                                           tag: 0)
        
        let favoriteSongController = FavoriteSongController()
        favoriteSongController.customTabBarController = self
        favoriteSongNavigationController = UINavigationController(rootViewController: favoriteSongController)
        favoriteSongNavigationController.tabBarItem = UITabBarItem(title: "Favorite",
                                                            image: UIImage(systemName: "star.fill"),
                                                            tag: 1)
        self.viewControllers = [
            homeNavigationController,
            favoriteSongNavigationController,
        ]
    }
    
    fileprivate func constraintPlayerView() {
        view.addSubview(playerView)
        playerView.snp.makeConstraints {
            $0.width.centerX.equalToSuperview()
            $0.height.equalTo(200)
            $0.bottom.equalTo(tabBar.snp.top).offset(300)
        }
    }
    
    ///hide or show player view
    fileprivate func hidePlayerView(_ shouldHide: Bool) {
        var bottomConstraint: CGFloat
        if shouldHide { //hide player
            bottomConstraint = 300
        } else { //show player
            bottomConstraint = 0
        }
        playerView.snp.updateConstraints {
            $0.bottom.equalTo(tabBar.snp.top).offset(bottomConstraint)
        }
    }
    
    // MARK: - AppRemote
    func appRemoteConnecting() {
        connectionIndicatorView.state = .connecting
    }

    func appRemoteConnected() {
        connectionIndicatorView.state = .connected
        subscribeToPlayerState()
        subscribeToCapabilityChanges()
        getPlayerState()
        enableInterface(true)
    }

    func appRemoteDisconnect() {
        connectionIndicatorView.state = .disconnected
        self.subscribedToPlayerState = false
        self.subscribedToCapabilities = false
        enableInterface(false)
    }

    // MARK: - Error & Alert
    func showError(_ errorDescription: String) {
        let alert = UIAlertController(title: "Error!", message: errorDescription, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    private func displayError(_ error: NSError?) {
        if let error = error {
            presentAlert(title: "Error", message: error.description)
        }
    }
    
    private func subscribeToPlayerState() {
        guard (!subscribedToPlayerState) else { return }
        appRemote?.playerAPI!.delegate = self
        appRemote?.playerAPI?.subscribe { (_, error) -> Void in
            guard error == nil else { return }
            self.subscribedToPlayerState = true
//            self.updatePlayerStateSubscriptionButtonState()
        }
    }
    // MARK: - User API
    private func fetchUserCapabilities() {
        appRemote?.userAPI?.fetchCapabilities(callback: { (capabilities, error) in
            guard error == nil else { return }
            let capabilities = capabilities as! SPTAppRemoteUserCapabilities
            print("⭐️⭐️⭐️⭐️⭐️USER fetchCapabilities \(capabilities)")
//            self.updateViewWithCapabilities(capabilities)
        })
    }

    private func subscribeToCapabilityChanges() {
        guard (!subscribedToCapabilities) else { return }
        appRemote?.userAPI?.delegate = self
        appRemote?.userAPI?.subscribe(toCapabilityChanges: { (success, error) in
            guard error == nil else { return }
            self.subscribedToCapabilities = true
//            self.updateCapabilitiesSubscriptionButtonState()
        })
    }

    private func unsubscribeFromCapailityChanges() {
        guard (subscribedToCapabilities) else { return }
        appRemote?.userAPI?.unsubscribe(toCapabilityChanges: { (success, error) in
            guard error == nil else { return }
            self.subscribedToCapabilities = false
//            self.updateCapabilitiesSubscriptionButtonState()
        })
    }
    
    private func getPlayerState() {
        appRemote?.playerAPI?.getPlayerState { (result, error) -> Void in
            guard error == nil else { return }

            let playerState = result as! SPTAppRemotePlayerState
            self.updateViewWithPlayerState(playerState)
        }
    }
    
    private func updateViewWithPlayerState(_ playerState: SPTAppRemotePlayerState) {
        print("⭐️⭐️⭐️⭐️⭐️implement updateViewWithPlayerState⭐️⭐️⭐️⭐️⭐️")
//        updatePlayPauseButtonState(playerState.isPaused)
//        updateRepeatModeLabel(playerState.playbackOptions.repeatMode)
//        updateShuffleLabel(playerState.playbackOptions.isShuffling)
//        trackNameLabel.text = playerState.track.name + " - " + playerState.track.artist.name
//        fetchAlbumArtForTrack(playerState.track) { (image) -> Void in
//            self.updateAlbumArtWithImage(image)
//        }
//        updateViewWithRestrictions(playerState.playbackRestrictions)
//        updateInterfaceForPodcast(playerState: playerState)
    }
    
//    private func updatePlayPauseButtonState(_ paused: Bool) {
//        let playPauseButtonImage = paused ? PlaybackButtonGraphics.playButtonImage() : PlaybackButtonGraphics.pauseButtonImage()
//        playPauseButton.setImage(playPauseButtonImage, for: UIControl.State())
//        playPauseButton.setImage(playPauseButtonImage, for: .highlighted)
//    }
    
    private func enableInterface(_ enabled: Bool = true) {
        print("⭐️⭐️⭐️⭐️⭐️Enable Interface⭐️⭐️⭐️⭐️⭐️")
//        buttons.forEach { (button) -> () in
//            button.isEnabled = enabled
//        }
//        if (!enabled) {
//            albumArtImageView.image = nil
//            updatePlayPauseButtonState(true);
//        }
    }
    
    func fetchFavoriteSongs(offset: Int, completion: @escaping () -> Void) {
        NetworkManager.fetchSavedTracks(offset: offset) { (result) in
            switch result {
            case .success(let savedTracks):
                self.savedTracks = savedTracks
            case .failure(let error):
                self.presentAlert(title: "Error Fetching Saved Tracks", message: error.localizedDescription)
            }
        }
    }
}

//MARK: Spotify Player Protocol
extension TabBarController: SpotifyPlayerProtocol {
    func openTrack(track: Track, openUrl: String, shouldOpen: Bool) {
        if shouldOpen {
            hidePlayerView(false)
            playerView.track = track
        } else {
            hidePlayerView(true)
            playerView.playButton.isSelected = false
        }
        if appRemote?.isConnected == true {
            if shouldOpen {
                appRemote?.playerAPI?.play(track.uri, callback: defaultCallback)
//                appRemote?.playerAPI?.resume(defaultCallback) //resume same song
            } else {
                appRemote?.playerAPI?.pause(defaultCallback)
            }
        } else { //if app remote is not connected
            if appRemote?.authorizeAndPlayURI(track.uri) == false { //// The Spotify app is not installed, present the user with an App Store page https://spotify.github.io/ios-sdk/html/Classes/SPTAppRemote.html#//api/name/connect
//                showAppStoreInstall()
                print("Spotify App not installed")
            } else {
                appRemote?.connectionParameters.accessToken = SpotifyAuth.current?.accessToken
                appRemote?.connect()
            }
        }
    }
    
    func playTrack(track: Track, shouldPlay: Bool) {
//        print("\n\n\(shouldPlay ? "Playing" : "Paused") Track \(track.name!) at \(track.uri!) AND \(track.href!)\n\n")
        if shouldPlay {
            hidePlayerView(false)
            playerView.playDelegate = self
            playerView.favoriteDelegate = self
            playerView.track = track
            playerView.playButton.isSelected = true
            playerView.playTrackFrom(urlString: track.previewUrl)
            if savedTracks.contains(where: { $0.track.id as! String == track.id as! String }) { //if track is favorited...
                playerView.favoriteButton.setImage(Constants.Images.heartFilled, for: .normal)
            } else {
                playerView.favoriteButton.setImage(Constants.Images.heart, for: .normal)
            }
        } else {
            hidePlayerView(true)
            playerView.playButton.isSelected = false
            playerView.player?.pause()
        }
    }
}

extension TabBarController: SpotifyFavoriteTrackProtocol {
    ///save track or remove it from saved tracks
    func favoriteTrack(track: Track, shouldFavorite: Bool) {
        guard let trackId = track.id as? String else { return }
        if shouldFavorite {
            Spartan.saveTracks(trackIds: [trackId], success: nil, failure: spartanCallbackError)
        } else {
            Spartan.removeSavedTracks(trackIds: [trackId], success: nil, failure: spartanCallbackError)
        }
    }
}

extension TabBarController {
    func playTrack(urlString: String) {
        playerView.playTrackFrom(urlString: urlString)
    }
}

// MARK: - SPTAppRemotePlayerStateDelegate
extension TabBarController: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        self.playerState = playerState
        print("⭐️⭐️⭐️⭐️⭐️playerStateDidChange \(playerState)")
//           updateViewWithPlayerState(playerState)
    }
}

// MARK: - SPTAppRemoteUserAPIDelegate
extension TabBarController: SPTAppRemoteUserAPIDelegate {
    func userAPI(_ userAPI: SPTAppRemoteUserAPI, didReceive capabilities: SPTAppRemoteUserCapabilities) {
        print("⭐️⭐️⭐️⭐️⭐️USER APIII \(capabilities)")
//        updateViewWithCapabilities(capabilities)
    }
}
