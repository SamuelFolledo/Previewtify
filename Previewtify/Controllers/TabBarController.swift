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
import StoreKit

class TabBarController: SwipeableTabBarController {
    
    //MARK: Properties
    public var savedTracks: [SavedTrack] = []
    private var playerState: SPTAppRemotePlayerState?
    private var connectionIndicatorView = ConnectionStatusIndicatorView()
    private var subscribedToPlayerState: Bool = false
    private var subscribedToCapabilities: Bool = false
    private var lastPlayerState: SPTAppRemotePlayerState?
    var defaultCallback: SPTAppRemoteCallback {
        get {
            return {[weak self] _, error in
                if let error = error {
                    self?.presentAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    var spartanCallbackError: (Error?) -> () {
        get {
            return {[weak self] error in
                if let error = error {
                    self?.presentAlert(title: "Spartan Error", message: error.localizedDescription)
                }
            }
        }
    }
    var appRemote: SPTAppRemote? {
        get { return (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appRemote }
    }
    
    //MARK: View Properties
    
    lazy var playerView: PlayerView = {
        let playerView = PlayerView(track: nil)
        playerView.playDelegate = self
        playerView.favoriteDelegate = self
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
    fileprivate func showPlayerView(_ shouldShow: Bool) {
        var bottomConstraint: CGFloat
        if shouldShow { //show player
            bottomConstraint = 0
        } else { //hide player
            bottomConstraint = 300
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
        showPlayerView(true)
    }

    func appRemoteDisconnect() {
        connectionIndicatorView.state = .disconnected
        self.subscribedToPlayerState = false
        self.subscribedToCapabilities = false
        showPlayerView(false)
    }

    // MARK: - Error & Alert
    
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
        playerView.track = nil
        playerView.spotifyTrack = playerState.track
        playerView.playButton.isSelected = !playerState.isPaused
        playerView.favoriteButton.isSelected = playerState.track.isSaved
//        playerView.trackNameLabel.text = playerState.track.name
//        playerView.artistNameLabel.text = playerState.track.artist.name
    }
    
    func fetchFavoriteSongs(offset: Int, completion: @escaping () -> Void) {
        NetworkManager.fetchSavedTracks(offset: offset) { (result) in
            switch result {
            case .success(let savedTracks):
                self.savedTracks = savedTracks
            case .failure(let error):
                self.presentAlert(title: "Error Fetching Saved Tracks", message: error.localizedDescription)
            }
            completion()
        }
    }
}

//MARK: Spotify Player Protocol
extension TabBarController: SpotifyPlayerProtocol {
    ///Protocol Method to for track with no previewUrl
    func openTrack(uri: String, shouldOpen: Bool) {
        playerView.updateTimerViews(shouldHide: true) //dont show slider
        showPlayerView(true)
        if appRemote?.isConnected == false { //if app remote is not connected
            if appRemote?.authorizeAndPlayURI(uri) == false { //// The Spotify app is not installed, present the user with an App Store page https://spotify.github.io/ios-sdk/html/Classes/SPTAppRemote.html#//api/name/connect
                showAppStoreInstall()
                return
            }
        }
        if shouldOpen { //play
            playerView.player?.pause()
            if let previewTrackUri = playerView.spotifyTrack?.uri, previewTrackUri == uri { //playing the same track... resume
                appRemote?.playerAPI?.resume(defaultCallback) //resume same song
            } else { //new track
                appRemote?.playerAPI?.play(uri, callback: defaultCallback)
            }
//            playerView.spotifyTrack = nil
//            playerView.track = track
            playerView.playButton.isSelected = true
        } else { //pause
            playerView.playButton.isSelected = false
            if playerState?.isPaused == true { return }
            appRemote?.playerAPI?.pause(defaultCallback)
        }
    }
    
    ///Protocol Method to play track's previewUrl
    func playTrack(track: Track, shouldPlay: Bool) {
        playerView.updateTimerViews(shouldHide: false)
        if !shouldPlay {
//            showPlayerView(false)
            self.playerView.playButton.isSelected = false
            self.playerView.player?.pause()
        }
        //set favorite button's image if it's favorited or not
        NetworkManager.checkIfFavorite(trackId: track.id as! String) { (isFavorite) in
            DispatchQueue.main.async {
                self.playerView.favoriteButton.isSelected = isFavorite
                if shouldPlay {
                    if self.playerState?.isPaused == false { //if appRemote is playing... pause
                        self.appRemote?.playerAPI?.pause(self.defaultCallback)
                    }
                    if let previewTrackId = self.playerView.track?.id as? String, previewTrackId == track.id as! String { //playing the same track... resume
                        self.playerView.player?.play()
                    } else { //new track
                        self.playerView.playTrackFrom(urlString: track.previewUrl)
                    }
                    self.showPlayerView(true)
                    self.playerView.spotifyTrack = nil
                    self.playerView.track = track
                    self.playerView.playButton.isSelected = true
                }
            }
        }
    }
}

extension TabBarController: SpotifyFavoriteTrackProtocol {
    ///save track or remove it from saved tracks
    func favoriteTrack(trackId: String, shouldFavorite: Bool) {
        if shouldFavorite {
            Spartan.saveTracks(trackIds: [trackId], success: nil, failure: spartanCallbackError)
        } else {
            Spartan.removeSavedTracks(trackIds: [trackId], success: nil, failure: spartanCallbackError)
        }
    }
}

extension TabBarController {
//    func playTrack(urlString: String) {
//        playerView.playTrackFrom(urlString: urlString)
//    }
}

// MARK: - SPTAppRemotePlayerStateDelegate
extension TabBarController: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        self.playerState = playerState
        updateViewWithPlayerState(playerState)
    }
}

// MARK: - SPTAppRemoteUserAPIDelegate
extension TabBarController: SPTAppRemoteUserAPIDelegate {
    func userAPI(_ userAPI: SPTAppRemoteUserAPI, didReceive capabilities: SPTAppRemoteUserCapabilities) {
        print("⭐️⭐️⭐️⭐️⭐️USER APIII \(capabilities)")
//        updateViewWithCapabilities(capabilities)
    }
}

//MARK: Spotify Methods
extension TabBarController {
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
    
//    func update(playerState: SPTAppRemotePlayerState) {
//        if lastPlayerState?.track.uri != playerState.track.uri {
////            fetchArtwork(for: playerState.track)
//        }
//        lastPlayerState = playerState
////        trackLabel.text = playerState.track.name
//        if playerState.isPaused {
//            print("Player should paused")
////            pauseAndPlayButton.setImage(UIImage(named: "playButton"), for: .normal)
//        } else {
//            print("Player should play")
////            pauseAndPlayButton.setImage(UIImage(named: "pauseButton"), for: .normal)
//        }
//    }

    func updateViewBasedOnConnected() {
        if appRemote?.isConnected == true {
            print("App remote is connected, Update views")
        } else { //show login
            let nav = UINavigationController(rootViewController: LoginController())
            self.view.window!.rootViewController = nav
        }
    }
    
//    func fetchPlayerState() {
//        appRemote?.playerAPI?.getPlayerState({ [weak self] (playerState, error) in
//            if let error = error {
//                print("Error getting player state:" + error.localizedDescription)
//            } else if let playerState = playerState as? SPTAppRemotePlayerState {
//                self?.update(playerState: playerState)
//            }
//        })
//    }
}

//MARK: StoreKit
extension TabBarController: SKStoreProductViewControllerDelegate {
    ///shows Spotify in the App Store if Spotify has not been downloaded
    private func showAppStoreInstall() {
        if TARGET_OS_SIMULATOR != 0 {
            presentAlert(title: "Simulator In Use", message: "The App Store is not available in the iOS simulator, please test this feature on a physical device.")
        } else {
            let loadingView = UIActivityIndicatorView(frame: view.bounds)
            view.addSubview(loadingView)
            loadingView.startAnimating()
            loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            let storeProductViewController = SKStoreProductViewController()
            storeProductViewController.delegate = self
            storeProductViewController.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier: SPTAppRemote.spotifyItunesItemIdentifier()], completionBlock: { (success, error) in
                loadingView.removeFromSuperview()
                if let error = error {
                    self.presentAlert(
                        title: "Error accessing App Store",
                        message: error.localizedDescription)
                } else {
                    self.present(storeProductViewController, animated: true, completion: nil)
                }
            })
        }
    }

    public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}
