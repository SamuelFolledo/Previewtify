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
    lazy var loginController = LoginController()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.makeKeyAndVisible()
        window!.windowScene = windowScene
        configureRootViewController()
    }
    
    //for spotify authorization and authentication flow
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        let parameters = loginController.appRemote.authorizationParameters(from: url)
        if let code = parameters?["code"] {
            NetworkManager.authorizationCode = code
            loginController.fetchSpotifyAccessToken()
        } else if let _ = parameters?[SPTAppRemoteAccessTokenKey] {
//            NetworkManager.accessToken = access_token
//            NetworkManager.spotifyAuth?.accessToken = access_token
        } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
            print("No access token error =", error_description)
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        if let _ = loginController.appRemote.connectionParameters.accessToken {
//            loginController.appRemote.connectionParameters.accessToken = accessToken
//            loginController.appRemote.connect()
        } else if let _ = SpotifyAuth.current?.accessToken {
//            loginController.appRemote.connectionParameters.accessToken = accessToken
//            loginController.appRemote.connect()
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        if let _ = User.current {
            
        } else {
            if loginController.appRemote.isConnected {
                loginController.appRemote.disconnect()
            }
        }
    }
}

extension SceneDelegate {
    func configureRootViewController() {
        if let _ = User.current { //if we have a user, then go to home
            window!.rootViewController = TabBarController()
            return
        }
        //go to log in
        let nav = UINavigationController(rootViewController: loginController)
        window!.rootViewController = nav
    }
}
