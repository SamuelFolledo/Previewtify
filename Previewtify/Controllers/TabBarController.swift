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
            $0.bottom.equalTo(tabBar.snp.top).offset(0)
//MARK: Spotify Player Protocol
extension TabBarController: SpotifyPlayerProtocol {
    func playTrack(track: Track, shouldPlay: Bool) {
        print("\n\n\(shouldPlay ? "Playing" : "Paused") Track \(track.name!) at \(track.uri!) AND \(track.href!)\n\n")
        if shouldPlay {
            hidePlayerView(false)
            playerView.track = track
        } else {
            hidePlayerView(true)
            playerView.playButton.isSelected = false
        }
        if appRemote?.isConnected == true {
            if shouldPlay {
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
}

extension TabBarController: SpotifyFavoriteTrackProtocol {
    func favoriteTrack(track: Track, shouldFavorite: Bool) {
        guard let trackId = track.id as? String else { return }
        if shouldFavorite {
            Spartan.saveTracks(trackIds: [trackId], success: nil, failure: spartanCallbackError)
        } else {
            Spartan.removeSavedTracks(trackIds: [trackId], success: nil, failure: spartanCallbackError)
        }
    }
}
    }
}
