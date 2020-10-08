//
//  NetworkManager.swift
//  Previewtify
//
//  Created by Samuel Folledo on 9/18/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import Foundation
import Spartan

class NetworkManager {
    //make it singleton
    public static let shared = NetworkManager()
    private init() {}
    //properties
    static let urlSession = URLSession.shared // shared singleton session object used to run tasks. Will be useful later
    static private let baseURL = "https://accounts.spotify.com/"
    static private var parameters: [String: String] = [:]
    static let clientId = "e9d953c9eff4433cb30acf3e4866a68d"
    static let clientSecretKey = "e891fd17090d4841afaf88c5730419a9"
    static let redirectUri = URL(string:"previewtify://")!
    static private let defaults = UserDefaults.standard
    static var codeVerifier: String = ""

    static var authorizationCode = defaults.string(forKey: Constants.authorizationCodeKey) {
        didSet { defaults.set(authorizationCode, forKey: Constants.authorizationCodeKey) }
    }

    static let configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: NetworkManager.clientId, redirectURL: NetworkManager.redirectUri)
        configuration.playURI = ""
        configuration.tokenSwapURL = URL(string: "http://localhost:1234/swap")
        configuration.tokenRefreshURL = URL(string: "http://localhost:1234/refresh")
        return configuration
    }()
    
    //MARK: Static Methods

    ///fetch accessToken from Spotify
    static func fetchAccessToken(completion: @escaping (Result<SpotifyAuth, Error>) -> Void) {
        guard let code = authorizationCode else { return completion(.failure(EndPointError.missing(message: "No authorization code found."))) }
        let url = URL(string: "\(baseURL)api/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let authorizationValue = "Basic \((clientId + ":" + clientSecretKey).data(using: .utf8)!.base64EncodedString())"
        request.allHTTPHeaderFields = ["Authorization": authorizationValue,
                                       "Content-Type": "application/x-www-form-urlencoded"]
        var requestBodyComponents = URLComponents()
        let scopeAsString = stringScopes.joined(separator: " ") //put array to string separated by whitespace
        requestBodyComponents.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: redirectUri.absoluteString),
            URLQueryItem(name: "code_verifier", value: codeVerifier),
            URLQueryItem(name: "scope", value: scopeAsString),
        ]
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,                              // is there data
                  let response = response as? HTTPURLResponse,  // is there HTTP response
                  (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
                  error == nil else {                           // was there no error, otherwise ...
                return completion(.failure(EndPointError.noData(message: "No data found")))
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase  //convert keys from snake case to camel case
            do {
                if let spotifyAuth = try? decoder.decode(SpotifyAuth.self, from: data) {
//                    self.accessToken = spotifyAuth.accessToken
//                    self.spotifyAuth = spotifyAuth
                    SpotifyAuth.setCurrent(spotifyAuth, writeToUserDefaults: true)
                    self.authorizationCode = nil
//                    self.refreshToken = spotifyAuth.refreshToken
                    Spartan.authorizationToken = spotifyAuth.accessToken
                    return completion(.success(spotifyAuth))
                }
                completion(.failure(EndPointError.couldNotParse(message: "Failed to decode data")))
            }
        }
        task.resume()
    }
    
    static func refreshAcessToken(completion: @escaping (Result<SpotifyAuth, Error>) -> Void) {
        guard let refreshToken = SpotifyAuth.current?.refreshToken else { return completion(.failure(EndPointError.missing(message: "No refresh token found."))) }
        let url = URL(string: "\(baseURL)api/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let spotifyAuthKey = "Basic \((clientId + ":" + clientSecretKey).data(using: .utf8)!.base64EncodedString())"
        request.allHTTPHeaderFields = ["Authorization": spotifyAuthKey,
                                       "Content-Type": "application/x-www-form-urlencoded"]
        var requestBodyComponents = URLComponents()
        requestBodyComponents.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken),
            URLQueryItem(name: "client_id", value: clientId),
        ]
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,                              // is there data
                  let response = response as? HTTPURLResponse,  // is there HTTP response
                  (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
                  error == nil else {                           // was there no error, otherwise ...
                return completion(.failure(EndPointError.noData(message: "No data found")))
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase  //convert keys from snake case to camel case
            do {
//                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]
//                print(jsonResult)
                if let spotifyAuth = try? decoder.decode(SpotifyAuth.self, from: data) {
                    //update access token
//                    self.accessToken = spotifyAuth.accessToken
//                    self.spotifyAuth?.accessToken = spotifyAuth.accessToken
                    guard var spotifyAuthToUpdate = SpotifyAuth.current else { return }
                    spotifyAuthToUpdate.accessToken = spotifyAuth.accessToken
                    spotifyAuthToUpdate.expiresIn = spotifyAuth.expiresIn
                    spotifyAuthToUpdate.scope = spotifyAuth.scope
                    SpotifyAuth.setCurrent(spotifyAuthToUpdate, writeToUserDefaults: true)
                    Spartan.authorizationToken = spotifyAuth.accessToken
                    print("Refreshed Access Token: \(spotifyAuth.accessToken)")
                    return completion(.success(spotifyAuth))
                }
                completion(.failure(EndPointError.couldNotParse(message: "Failed to decode data")))
            }
        }
        task.resume()
    }
    
    ///fetch user with an unexpired access token
    static func fetchUser(accessToken: String, completion: @escaping (Result<PrivateUser, Error>) -> Void) {
        Spartan.authorizationToken = accessToken
        _ = Spartan.getMe(success: { (user) in
            // Do something with the user object
            completion(.success(user))
        }, failure: { (error) in
            if error.errorType == .unauthorized {
                print("Refresh token!")
                return
            }
            completion(.failure(error))
        })
    }
    
    static func checkIfFavorite(trackId: String, completion: @escaping (_ savedBools: Bool) -> Void) {
        Spartan.tracksAreSaved(trackIds: [trackId]) { (savedBools) in
            guard let isSaved = savedBools.first else { return }
            completion(isSaved)
        } failure: { (error) in
            print("Error check if track is saved")
        }

    }
    //MARK: Helpers
}
