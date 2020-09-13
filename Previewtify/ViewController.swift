//
//  ViewController.swift
//  Previewtify
//
//  Created by Samuel Folledo on 9/9/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit
import CryptoKit //for SHA256
//import AuthenticationServices

class ViewController: UIViewController, SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
    
    var codeVerifier: String = ""
    ///code from login callback
    var responseTypeCode: String? {
        didSet {
            fetchSpotifyToken { (dictionary, error) in
                if let error = error {
                    print("Token request error \(error)")
                    return
                }
                let accessToken = dictionary!["access_token"] as! String
                self.accessToken = accessToken
                self.appRemote.connectionParameters.accessToken = accessToken
                self.appRemote.connect()
            }
        }
    }
    var accessToken: String? {
        didSet {
            print("Got access token!! \(accessToken!)")
        }
    }
    private let SpotifyClientID = "e9d953c9eff4433cb30acf3e4866a68d"
    private let SpotifyClientSecretKey = "e891fd17090d4841afaf88c5730419a9"
    private let SpotifyRedirectURI = URL(string: "previewtify://")!

    lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: SpotifyClientID, redirectURL: SpotifyRedirectURI)
        // Set the playURI to a non-nil value so that Spotify plays music after authenticating and App Remote can connect
        // otherwise another app switch will be required
        configuration.playURI = ""

        // Set these url's to your backend which contains the secret to exchange for an access token
        // You can use the provided ruby script spotify_token_swap.rb for testing purposes
        configuration.tokenSwapURL = URL(string: "http://localhost:1234/swap")
        configuration.tokenRefreshURL = URL(string: "http://localhost:1234/refresh")
        return configuration
    }()

    lazy var sessionManager: SPTSessionManager = {
        let manager = SPTSessionManager(configuration: configuration, delegate: self)
        return manager
    }()

    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = accessToken
        appRemote.delegate = self
        return appRemote
    }()

    private var lastPlayerState: SPTAppRemotePlayerState?

    // MARK: - Subviews

    private lazy var connectLabel: UILabel = {
        let label = UILabel()
        label.text = "Connect your Spotify account"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor(red:(29.0 / 255.0), green:(185.0 / 255.0), blue:(84.0 / 255.0), alpha:1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var connectButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(red:(29.0 / 255.0), green:(185.0 / 255.0), blue:(84.0 / 255.0), alpha:1.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 11.75, left: 32.0, bottom: 11.75, right: 32.0)
        button.layer.cornerRadius = 20.0
        button.setTitle("Continue with Spotify", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    private lazy var disconnectButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(red:(29.0 / 255.0), green:(185.0 / 255.0), blue:(84.0 / 255.0), alpha:1.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 11.75, left: 32.0, bottom: 11.75, right: 32.0)
        button.layer.cornerRadius = 20.0
        button.setTitle("Sign out", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return button
    }()
//    private lazy var connectButton = ConnectButton(title: "Continue with Spotify")
//    private lazy var disconnectButton = ConnectButton(title: "Sign out")

    private lazy var pauseAndPlayButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didTapPauseOrPlay), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var trackLabel: UILabel = {
        let trackLabel = UILabel()
        trackLabel.translatesAutoresizingMaskIntoConstraints = false
        trackLabel.textColor = .black
        trackLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        trackLabel.textAlignment = .center
        return trackLabel
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        view.addSubview(connectLabel)
        view.addSubview(connectButton)
        view.addSubview(disconnectButton)
        view.addSubview(imageView)
        view.addSubview(trackLabel)
        view.addSubview(pauseAndPlayButton)

        let constant: CGFloat = 16.0

        connectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        connectButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        disconnectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        disconnectButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true

        connectLabel.centerXAnchor.constraint(equalTo: connectButton.centerXAnchor).isActive = true
        connectLabel.bottomAnchor.constraint(equalTo: connectButton.topAnchor, constant: -constant).isActive = true

        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 64).isActive = true
        imageView.bottomAnchor.constraint(equalTo: trackLabel.topAnchor, constant: -constant).isActive = true

        trackLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        trackLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: constant).isActive = true
        trackLabel.bottomAnchor.constraint(equalTo: connectLabel.topAnchor, constant: -constant).isActive = true

        pauseAndPlayButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pauseAndPlayButton.topAnchor.constraint(equalTo: trackLabel.bottomAnchor, constant: constant).isActive = true
        pauseAndPlayButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        pauseAndPlayButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        pauseAndPlayButton.sizeToFit()

        connectButton.sizeToFit()
        disconnectButton.sizeToFit()

        connectButton.addTarget(self, action: #selector(didTapConnect(_:)), for: .touchUpInside)
        disconnectButton.addTarget(self, action: #selector(didTapDisconnect(_:)), for: .touchUpInside)

        updateViewBasedOnConnected()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateViewBasedOnConnected()
    }

    func update(playerState: SPTAppRemotePlayerState) {
        if lastPlayerState?.track.uri != playerState.track.uri {
            fetchArtwork(for: playerState.track)
        }
        lastPlayerState = playerState
        trackLabel.text = playerState.track.name
        if playerState.isPaused {
            pauseAndPlayButton.setImage(UIImage(named: "play"), for: .normal)
        } else {
            pauseAndPlayButton.setImage(UIImage(named: "pause"), for: .normal)
        }
    }

    func updateViewBasedOnConnected() {
        if (appRemote.isConnected) {
            connectButton.isHidden = true
            disconnectButton.isHidden = false
            connectLabel.isHidden = true
            imageView.isHidden = false
            trackLabel.isHidden = false
            pauseAndPlayButton.isHidden = false
        } else { //show login
            disconnectButton.isHidden = true
            connectButton.isHidden = false
            connectLabel.isHidden = false
            imageView.isHidden = true
            trackLabel.isHidden = true
            pauseAndPlayButton.isHidden = true
        }
    }

    func fetchArtwork(for track:SPTAppRemoteTrack) {
        appRemote.imageAPI?.fetchImage(forItem: track, with: CGSize.zero, callback: { [weak self] (image, error) in
            if let error = error {
                print("Error fetching track image: " + error.localizedDescription)
            } else if let image = image as? UIImage {
                self?.imageView.image = image
            }
        })
    }

    func fetchPlayerState() {
        appRemote.playerAPI?.getPlayerState({ [weak self] (playerState, error) in
            if let error = error {
                print("Error getting player state:" + error.localizedDescription)
            } else if let playerState = playerState as? SPTAppRemotePlayerState {
                self?.update(playerState: playerState)
            }
        })
    }

    // MARK: - Actions

    @objc func didTapPauseOrPlay(_ button: UIButton) {
        if let lastPlayerState = lastPlayerState, lastPlayerState.isPaused {
            appRemote.playerAPI?.resume(nil)
        } else {
            appRemote.playerAPI?.pause(nil)
        }
    }

    @objc func didTapDisconnect(_ button: UIButton) {
        if (appRemote.isConnected) {
            appRemote.disconnect()
        }
    }

    @objc func didTapConnect(_ button: UIButton) {
        /*
         Scopes let you specify exactly what types of data your application wants to
         access, and the set of scopes you pass in your call determines what access
         permissions the user is asked to grant.
         For more information, see https://developer.spotify.com/web-api/using-scopes/.
         */
        let scope: SPTScope = [.appRemoteControl, .playlistReadPrivate]

        if #available(iOS 11, *) {
            // Use this on iOS 11 and above to take advantage of SFAuthenticationSession
            sessionManager.initiateSession(with: scope, options: .clientOnly)
        } else {
            // Use this on iOS versions < 11 to use SFSafariViewController
            sessionManager.initiateSession(with: scope, options: .clientOnly, presenting: self)
        }
//        authorizeWithSpotify { (dic, error) in
//            if let error = error {
//                print("ERROR authorizing with Spotify \(error.localizedDescription)")
//                return
//            }
//            print("WE GOR DicrionEYYY \(dic)")
//        }
    }


    // MARK: - SPTSessionManagerDelegate

    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        if error.localizedDescription == "The operation couldn’t be completed. (com.spotify.sdk.login error 1.)" {
            authorizeWithSpotify { (dic, error) in
                if let error = error {
                    print("ERROR authorizing with Spotify \(error.localizedDescription)")
                    return
                }
            }
        } else {
            presentAlertController(title: "Authorization Failed", message: error.localizedDescription, buttonTitle: "Bummer")
        }
    }

    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        presentAlertController(title: "Session Renewed", message: session.description, buttonTitle: "Sweet")
    }

    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        appRemote.connectionParameters.accessToken = session.accessToken
        appRemote.connect()
    }

    // MARK: - SPTAppRemoteDelegate

    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
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

    // MARK: - SPTAppRemotePlayerAPIDelegate

    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        debugPrint("Spotify Track name: %@", playerState.track.name)
        update(playerState: playerState)
    }

    // MARK: - Private Helpers

    private func presentAlertController(title: String, message: String, buttonTitle: String) {
        DispatchQueue.main.async {
            let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
            controller.addAction(action)
            self.present(controller, animated: true)
        }
    }
    
    //MARK: POST Request
    func authorizeWithSpotify(completion: @escaping ([String: Any]?, Error?) -> Void) {
        guard let data = "SecretPassword".data(using: .utf8) else { return }
        let digest = SHA256.hash(data: data)
        let digestString = digest.map { String(format: "%02X", $0) }.joined()
        let codeChallengeMethod = Data(digestString.utf8).base64EncodedString()
        codeVerifier = codeChallengeMethod
        print("CODE VERIFIER = \(codeVerifier.count) \t \(codeVerifier)")
        
        var components = URLComponents(string: "https://accounts.spotify.com/authorize")!
        let parameters = [
            "client_id" : SpotifyClientID,
            "response_type": "code",
            "redirect_uri": SpotifyRedirectURI.absoluteString,
            "code_challenge_method": "S256",
            "code_challenge": codeVerifier,
//            "scope": "user-read-private user-read-email",
//            "state": "e21392da45dbf4",
        ]
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        var request = URLRequest(url: components.url!)
        print("Request Authorize URL=", request.url!.absoluteString)
        request.httpMethod = "GET"

//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.allHTTPHeaderFields = [//"Authorization": SpotifyAuthKey,
//                                        "Content-Type": "application/x-www-form-urlencoded"
//                                    ]
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,                            // is there data
                let response = response as? HTTPURLResponse,  // is there HTTP response
                (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
                error == nil else {                           // was there no error, otherwise ...
                    print("FAILED!!")
                    completion(nil, error)
                    return
            }
//            let responseObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
//            print("RESPONSE OBJECT=", responseObject)
            if let returnData = String(data: data, encoding: .utf8) {
                print("RESULT \(returnData)")
            } else {
                print("Nada")
//              completion("")
            }
//            completion(responseObject, nil)
        }
        task.resume()
    }
    
    func fetchSpotifyToken(completion: @escaping ([String: Any]?, Error?) -> Void) {
        let url = URL(string: "https://accounts.spotify.com/api/token")!
        var request = URLRequest(url: url)
        print("Request URL=", request.url!.absoluteString)
        request.httpMethod = "POST"
        
        let SpotifyAuthKey = "Basic \((SpotifyClientID + ":" + SpotifyClientSecretKey).data(using: .utf8)!.base64EncodedString())"
        request.allHTTPHeaderFields = ["Authorization": SpotifyAuthKey,
                                       "Content-Type": "application/x-www-form-urlencoded"]
        do {
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems = [
                URLQueryItem(name: "client_id", value: SpotifyClientID),
                URLQueryItem(name: "grant_type", value: "authorization_code"),
                URLQueryItem(name: "code", value: responseTypeCode!),
                URLQueryItem(name: "redirect_uri", value: SpotifyRedirectURI.absoluteString),
                URLQueryItem(name: "code_verifier", value: codeVerifier),
                URLQueryItem(name: "scope", value: "user-read-private user-read-email"),
            ]
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data,                            // is there data
                    let response = response as? HTTPURLResponse,  // is there HTTP response
                    (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
                    error == nil else {                           // was there no error, otherwise ...
                        print("FAILED!!")
                        completion(nil, error)
                        return
                }
                //            guard let result = try? JSONDecoder().decode(ArticleList.self, from: data) else {}
                let responseObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
                print("RESPONSE OBJECT=", responseObject)
                completion(responseObject, nil)
            }
            task.resume()
        } catch {
            print("Error JSONing")
        }
    }
    
    func sendPostRequest1(completion: @escaping ([String: Any]?, Error?) -> Void) {
        guard let data = "SecretPassword".data(using: .utf8) else { return }
        let digest = SHA256.hash(data: data)
        let digestString = digest.map { String(format: "%02X", $0) }.joined()
        let codeChallengeMethod = Data(digestString.utf8).base64EncodedString()
        codeVerifier = codeChallengeMethod
        print("CODE CHALLENGE count = \(codeChallengeMethod.count) \t \(codeChallengeMethod)")
        let url = "https://accounts.spotify.com/authorize"
        //            let rootUrl = "https://accounts.spotify.com/api/token"
        let parameters: [String: String] = [
            "client_id": SpotifyClientID,
            "response_type": "code",
            "redirect_uri": SpotifyRedirectURI.absoluteString,
            "code_challenge_method": codeChallengeMethod,
            "code_challenge": "S256",
//            "scope": "user-read-private user-read-email",
            "scope": "user-read-private user-read-email",
            //                "state": "34fFs29kd09",
        ]

        var components = URLComponents(string: url)!
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        var request = URLRequest(url: components.url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        print("Request URL=", request.url!.absoluteString)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,                            // is there data
                let response = response as? HTTPURLResponse,  // is there HTTP response
                (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
                error == nil else {                           // was there no error, otherwise ...
                    print("FAILED!!")
                    completion(nil, error)
                    return
            }
//            guard let result = try? JSONDecoder().decode(ArticleList.self, from: data) else {}
            let responseObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
            print("RESPONSE OBJECT=", responseObject)
            completion(responseObject, nil)
        }
        task.resume()
    }
    
    func sendRequest(_ url: String, parameters: [String: String], completion: @escaping ([String: Any]?, Error?) -> Void) {
        var components = URLComponents(string: url)!
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        var request = URLRequest(url: components.url!)
        print("URL=\(request.url!.absoluteString)")
        request.allHTTPHeaderFields = [
            //            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "Basic \(SpotifyClientID):e891fd17090d4841afaf88c5730419a9"
            //            "client_id": SpotifyClientID,
            //            "client_secret": "e891fd17090d4841afaf88c5730419a9"
        ]
        request.httpMethod = "GET"
        
        //        let loginString = "Basic \(SpotifyClientID.data(using: .utf8)?.base64EncodedString()):\(SpotifyClientSecretKey.data(using: .utf8)?.base64EncodedString())"
        //        let loginData = loginString.data(using: String.Encoding.utf8)!
        //        let base64LoginString = loginData.base64EncodedString()
        //        request.setValue("\(loginString)", forHTTPHeaderField: "Authorization")
        //        print(loginString)
        
//        let loginString = "\(SpotifyClientID):\(SpotifyClientSecretKey)"
//        let loginData = loginString.data(using: String.Encoding.utf8)!
//        let base64LoginString = loginData.base64EncodedString()
//        request.setValue("Basic *<\(base64LoginString)>*", forHTTPHeaderField: "Authorization")
//        print(base64LoginString)
        //        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,                            // is there data
                let response = response as? HTTPURLResponse,  // is there HTTP response
                (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
                error == nil else {                           // was there no error, otherwise ...
                    print("FAILED!!")
                    completion(nil, error)
                    return
            }
            //            guard let result = try? JSONDecoder().decode(ArticleList.self, from: data) else {}
            let responseObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
            print("RESPONSE=", responseObject)
            completion(responseObject, nil)
        }
        task.resume()
    }
    
    
//    func sendRequest(_ url: String, parameters: [String: String], completion: @escaping ([String: Any]?, Error?) -> Void) {
//            var components = URLComponents(string: url)!
//            components.queryItems = parameters.map { (key, value) in
//                URLQueryItem(name: key, value: value)
//            }
//            components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
//            var request = URLRequest(url: components.url!)
//    //        request.allHTTPHeaderFields = [
//    ////            "Accept": "application/json",
//    ////            "Content-Type": "application/json",
//    //            "Authorization": "Basic *\(SpotifyClientID):e891fd17090d4841afaf88c5730419a9*"
//    ////            "client_id": SpotifyClientID,
//    ////            "client_secret": "e891fd17090d4841afaf88c5730419a9"
//    //        ]
//
//    //        let loginString = "Basic \(SpotifyClientID.data(using: .utf8)?.base64EncodedString()):\(SpotifyClientSecretKey.data(using: .utf8)?.base64EncodedString())"
//    //        let loginData = loginString.data(using: String.Encoding.utf8)!
//    //        let base64LoginString = loginData.base64EncodedString()
//    //        request.setValue("\(loginString)", forHTTPHeaderField: "Authorization")
//    //        print(loginString)
//
//            let loginString = "\(SpotifyClientID):\(SpotifyClientSecretKey)"
//            let loginData = loginString.data(using: String.Encoding.utf8)!
//            let base64LoginString = loginData.base64EncodedString()
//            request.setValue("Basic *<\(base64LoginString)>*", forHTTPHeaderField: "Authorization")
//            print(base64LoginString)
//    //        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//    //        request.addValue("application/json", forHTTPHeaderField: "Accept")
//            request.httpMethod = "POST"
//            let task = URLSession.shared.dataTask(with: request) { data, response, error in
//                guard let data = data,                            // is there data
//                    let response = response as? HTTPURLResponse,  // is there HTTP response
//                    (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
//                    error == nil else {                           // was there no error, otherwise ...
//                        print("FAILED!!")
//                        completion(nil, error)
//                        return
//                }
//    //            guard let result = try? JSONDecoder().decode(ArticleList.self, from: data) else {}
//                let responseObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
//                completion(responseObject, nil)
//            }
//            task.resume()
//        }
}

