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

class ViewController: UIViewController {
    
    var codeVerifier: String = ""
    
    var responseTypeCode: String? {
        didSet {
            fetchSpotifyToken { (dictionary, error) in
                if let error = error {
                    print("Fetching token request error \(error)")
                    return
                }
                let accessToken = dictionary!["access_token"] as! String
                DispatchQueue.main.async {
                    self.appRemote.connectionParameters.accessToken = accessToken
                    self.appRemote.connect()
                }
            }
        }
    }
    
    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }()

    var accessToken = UserDefaults.standard.string(forKey: accessTokenKey) {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(accessToken, forKey: accessTokenKey)
        }
    }

    lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: spotifyClientId, redirectURL: redirectUri)
        // Set the playURI to a non-nil value so that Spotify plays music after authenticating and App Remote can connect
        // otherwise another app switch will be required
        configuration.playURI = ""
        // Set these url's to your backend which contains the secret to exchange for an access token
        // You can use the provided ruby script spotify_token_swap.rb for testing purposes
        configuration.tokenSwapURL = URL(string: "http://localhost:1234/swap")
        configuration.tokenRefreshURL = URL(string: "http://localhost:1234/refresh")
        return configuration
    }()
    
    lazy var sessionManager: SPTSessionManager? = {
        let manager = SPTSessionManager(configuration: configuration, delegate: self)
        return manager
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

    //MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateViewBasedOnConnected()
    }
    
    //MARK: Methods
    func setupViews() {
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
        if appRemote.isConnected == true {
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

    func fetchArtwork(for track: SPTAppRemoteTrack) {
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
        if appRemote.isConnected == true {
            appRemote.disconnect()
        }
    }

    @objc func didTapConnect(_ button: UIButton) {
        guard let sessionManager = sessionManager else { return }
        

        if #available(iOS 11, *) {
            // Use this on iOS 11 and above to take advantage of SFAuthenticationSession
            sessionManager.initiateSession(with: scope, options: .clientOnly)
        } else {
            // Use this on iOS versions < 11 to use SFSafariViewController
            sessionManager.initiateSession(with: scope, options: .clientOnly, presenting: self)
        }
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
    
    ///get the code from spotify to be used to get user's token
//    func authorizeWithSpotify(completion: @escaping ([String: Any]?, Error?) -> Void) {
//        guard let data = "SecretPassword".data(using: .utf8) else { return }
//        let digest = SHA256.hash(data: data)
//        let digestString = digest.map { String(format: "%02X", $0) }.joined()
//        let codeChallengeMethod = Data(digestString.utf8).base64EncodedString()
//        codeVerifier = codeChallengeMethod
//        print("CODE VERIFIER = \(codeVerifier.count) \t \(codeVerifier)")
//
//        var components = URLComponents(string: "https://accounts.spotify.com/authorize")!
//        let parameters = [
//            "client_id" : SpotifyClientID,
//            "response_type": "code",
//            "redirect_uri": SpotifyRedirectURI.absoluteString,
//            "code_challenge_method": "S256",
//            "code_challenge": codeVerifier,
////            "scope": "user-read-private user-read-email",
////            "state": "e21392da45dbf4",
//        ]
//        components.queryItems = parameters.map { (key, value) in
//            URLQueryItem(name: key, value: value)
//        }
//        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
//
//        var request = URLRequest(url: components.url!)
//        print("Request Authorize URL=", request.url!.absoluteString)
//        request.httpMethod = "GET"
//
////        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
////        request.allHTTPHeaderFields = [//"Authorization": SpotifyAuthKey,
////                                        "Content-Type": "application/x-www-form-urlencoded"
////                                    ]
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data,                            // is there data
//                let response = response as? HTTPURLResponse,  // is there HTTP response
//                (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
//                error == nil else {                           // was there no error, otherwise ...
//                    print("FAILED!!")
//                    completion(nil, error)
//                    return
//            }
////            let responseObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
////            print("RESPONSE OBJECT=", responseObject)
//            if let returnData = String(data: data, encoding: .utf8) {
//                print("RESULT \(returnData)")
//            } else {
//                print("Nada")
////              completion("")
//            }
////            completion(responseObject, nil)
//        }
//        task.resume()
//    }
    
    func fetchSpotifyToken(completion: @escaping ([String: Any]?, Error?) -> Void) {
        let url = URL(string: "https://accounts.spotify.com/api/token")!
        var request = URLRequest(url: url)
        print("Request URL=", request.url!.absoluteString)
        request.httpMethod = "POST"
        let clientId = spotifyClientId
        let secretKey = spotifyClientSecretKey
        let spotifyAuthKey = "Basic \((clientId + ":" + secretKey).data(using: .utf8)!.base64EncodedString())"
        request.allHTTPHeaderFields = ["Authorization": spotifyAuthKey,
                                       "Content-Type": "application/x-www-form-urlencoded"]
        do {
            var requestBodyComponents = URLComponents()
            requestBodyComponents.queryItems = [
                URLQueryItem(name: "client_id", value: clientId),
                URLQueryItem(name: "grant_type", value: "authorization_code"),
                URLQueryItem(name: "code", value: responseTypeCode!),
                URLQueryItem(name: "redirect_uri", value: redirectUri.absoluteString),
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
    
//    func sendPostRequest1(completion: @escaping ([String: Any]?, Error?) -> Void) {
//        guard let data = "SecretPassword".data(using: .utf8) else { return }
//        let digest = SHA256.hash(data: data)
//        let digestString = digest.map { String(format: "%02X", $0) }.joined()
//        let codeChallengeMethod = Data(digestString.utf8).base64EncodedString()
//        codeVerifier = codeChallengeMethod
//        print("CODE CHALLENGE count = \(codeChallengeMethod.count) \t \(codeChallengeMethod)")
//        let url = "https://accounts.spotify.com/authorize"
//        //            let rootUrl = "https://accounts.spotify.com/api/token"
//        let clientId = SceneDelegate.spotifyClientId
//        let redirectUri = SceneDelegate.redirectUri
//        let parameters: [String: String] = [
//            "client_id": clientId,
//            "response_type": "code",
//            "redirect_uri": redirectUri.absoluteString,
//            "code_challenge_method": codeChallengeMethod,
//            "code_challenge": "S256",
////            "scope": "user-read-private user-read-email",
//            "scope": "user-read-private user-read-email",
//            //                "state": "34fFs29kd09",
//        ]
//
//        var components = URLComponents(string: url)!
//        components.queryItems = parameters.map { (key, value) in
//            URLQueryItem(name: key, value: value)
//        }
//        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
//        var request = URLRequest(url: components.url!)
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        print("Request URL=", request.url!.absoluteString)
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data,                            // is there data
//                let response = response as? HTTPURLResponse,  // is there HTTP response
//                (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
//                error == nil else {                           // was there no error, otherwise ...
//                    print("FAILED!!")
//                    completion(nil, error)
//                    return
//            }
////            guard let result = try? JSONDecoder().decode(ArticleList.self, from: data) else {}
//            let responseObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
//            print("RESPONSE OBJECT=", responseObject)
//            completion(responseObject, nil)
//        }
//        task.resume()
//    }
}

// MARK: - SPTAppRemoteDelegate
extension ViewController: SPTAppRemoteDelegate {
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
}

// MARK: - SPTAppRemotePlayerAPIDelegate
extension ViewController: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        debugPrint("Spotify Track name: %@", playerState.track.name)
        update(playerState: playerState)
    }
}

// MARK: - SPTSessionManagerDelegate
extension ViewController: SPTSessionManagerDelegate {
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        if error.localizedDescription == "The operation couldn’t be completed. (com.spotify.sdk.login error 1.)" {
            print("AUTHENTICATE with WEBAPI")
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
}
