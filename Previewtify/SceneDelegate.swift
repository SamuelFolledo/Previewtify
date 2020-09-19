//
//  SceneDelegate.swift
//  Previewtify
//
//  Created by Samuel Folledo on 9/9/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    lazy var rootViewController = ViewController()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.makeKeyAndVisible()
        window!.windowScene = windowScene
        if let _ = User.current { //if we have a user, then go to home
            let nav = UINavigationController(rootViewController: HomeController())
            window!.rootViewController = nav
            return
        }
        //go to log in
        let nav = UINavigationController(rootViewController: rootViewController)
        window!.rootViewController = nav
    }
    
    //for spotify authorization and authentication flow
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        let parameters = rootViewController.appRemote.authorizationParameters(from: url)
        if let code = parameters?["code"] {
            NetworkManager.authorizationCode = code
            rootViewController.fetchSpotifyAccessToken()
        } else if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            NetworkManager.accessToken = access_token
        } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
            print("No access token error =", error_description)
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        if let _ = rootViewController.appRemote.connectionParameters.accessToken {
//            rootViewController.appRemote.connectionParameters.accessToken = accessToken
//            rootViewController.appRemote.connect()
        } else if let _ = NetworkManager.accessToken {
//            rootViewController.appRemote.connectionParameters.accessToken = accessToken
//            rootViewController.appRemote.connect()
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        if let _ = User.current {
            
        } else {
            if rootViewController.appRemote.isConnected {
                rootViewController.appRemote.disconnect()
            }
        }
    }
}
