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
    
    static var totalCount: Int = Int.max
    static var codeVerifier: String = ""

    static var accessToken = defaults.string(forKey: Constants.accessTokenKey) {
        didSet { defaults.set(accessToken, forKey: Constants.accessTokenKey) }
    }
    static var authorizationCode = defaults.string(forKey: Constants.authorizationCodeKey) {
        didSet { defaults.set(authorizationCode, forKey: Constants.authorizationCodeKey) }
    }
    static var refreshToken = defaults.string(forKey: Constants.refreshTokenKey) {
        didSet { defaults.set(refreshToken, forKey: Constants.refreshTokenKey) }
    }

    static let configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: NetworkManager.clientId, redirectURL: NetworkManager.redirectUri)
        configuration.playURI = ""
        configuration.tokenSwapURL = URL(string: "http://localhost:1234/swap")
        configuration.tokenRefreshURL = URL(string: "http://localhost:1234/refresh")
        return configuration
    }()
    

///Updates parameters
    static func updateParameters(parameters: [String: String]) {
        for parameter in parameters.compactMapValues({ $0 }) where parameter.value != "" { //compactMapValues removes nil values, and ensures it will not read "" values
//            self.parameters[parameter.key] = parameter.value
        }
    }

    static func resetNetworkManager() { //reset totalCount and parameters
        totalCount = Int.max
//        parameters = [kPAGE: "0", kPAGESIZE: "20"]
    }

    ///fetch accessToken from Spotify
    static func fetchAccessToken(completion: @escaping (Result<SpotifyAuth, Error>) -> Void) {
        let url = URL(string: "https://accounts.spotify.com/api/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let spotifyAuthKey = "Basic \((clientId + ":" + clientSecretKey).data(using: .utf8)!.base64EncodedString())"
        request.allHTTPHeaderFields = ["Authorization": spotifyAuthKey,
                                       "Content-Type": "application/x-www-form-urlencoded"]
        do {
            var requestBodyComponents = URLComponents()
            let scopeAsString = stringScopes.joined(separator: " ") //put array to string separated by whitespace
            requestBodyComponents.queryItems = [
                URLQueryItem(name: "client_id", value: clientId),
                URLQueryItem(name: "grant_type", value: "authorization_code"),
                URLQueryItem(name: "code", value: authorizationCode!),
                URLQueryItem(name: "redirect_uri", value: redirectUri.absoluteString),
                URLQueryItem(name: "code_verifier", value: codeVerifier),
                URLQueryItem(name: "scope", value: scopeAsString),
            ]
            request.httpBody = requestBodyComponents.query?.data(using: .utf8)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data,                            // is there data
                    let response = response as? HTTPURLResponse,  // is there HTTP response
                    (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
                    error == nil else {                           // was there no error, otherwise ...
                        return completion(.failure(EndPointError.noData(message: "No data found")))
                }
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase //convert keys from snake case to camel case
                if let spotifyAuth = try? decoder.decode(SpotifyAuth.self, from: data) {
                    self.accessToken = spotifyAuth.accessToken
                    Spartan.authorizationToken = spotifyAuth.accessToken
                    return completion(.success(spotifyAuth))
                }
                completion(.failure(EndPointError.couldNotParse(message: "Failed to decode data")))
            }
            task.resume()
        }
    }
    
    static func fetchUser(accessToken: String, completion: @escaping (Result<User, Error>) -> Void) {
        Spartan.authorizationToken = accessToken
        _ = Spartan.getMe(success: { (user) in
            // Do something with the user object
            let user = User(user: user)
            User.setCurrent(user, writeToUserDefaults: true)
            completion(.success(user))
        }, failure: { (error) in
            if error.errorType == .unauthorized {
                print("Refresh token!")
                return
            }
            completion(.failure(error))
        })
    }
    
    
    //MARK: Helpers
}
