//
//  TabBarController.swift
//  Previewtify
//
//  Created by Samuel Folledo on 9/30/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import SnapKit
import SwipeableTabBarController

class TabBarController: SwipeableTabBarController {
    
    //MARK: Properties
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
        }
    }
}
