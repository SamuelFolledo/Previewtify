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
//        let url = URL(string: "https://accounts.spotify.com/v1/me")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
////        let spotifyAuthKey = "Basic \((clientId + ":" + clientSecretKey).data(using: .utf8)!.base64EncodedString())"
//        request.allHTTPHeaderFields = [
//                                        "Accept": "application/json",
//                                        "Content-Type": "application/json",
//                                        "Authorization": "Bearer \(accessToken!)"
//        ]
//        do {
//            let task = URLSession.shared.dataTask(with: request) { data, response, error in
//                if let error = error {
//                    return completion(.failure(error))
//                }
//                guard let data = data,                              // is there data
//                      let response = response as? HTTPURLResponse,  // is there HTTP response
//                      (200 ..< 300) ~= response.statusCode          // is statusCode 2XX
//                else {                           // was there no error, otherwise ...
//                    return completion(.failure(EndPointError.noData(message: "No data found")))
//                }
////                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]
//                let responseObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
//                print(responseObject)
//
//                //            let decoder = JSONDecoder()
//                //            decoder.keyDecodingStrategy = .convertFromSnakeCase //convert keys from snake case to camel case
//                //            if let spotifyAuth = try? decoder.decode(SpotifyAuth.self, from: data) {
//                //                return completion(.success(spotifyAuth))
//                //            }
//                //            completion(.failure(EndPointError.couldNotParse(message: "Failed to decode data")))
//            }
//            task.resume()
//        }
    }
    
    
//    static func fetchNewsApi(endpoint: EndPoints, parameters: [String: String] = [:], completion: @escaping (Result<[Article], Error>) -> Void) {
//        updateParameters(parameters: parameters)
//        switch endpoint {
//        case .articles, .category, .country, .topHeadline, .source, .language: //these endpoints all receives an array of articles
//            fetchArticles(endpoint: endpoint) { (result) in //fetch articles
//                switch result {
//                case let .success(articles):
//                    completion(.success(articles))
//                case let .failure(error):
//                    completion(.failure(error))
//                }
//            }
//        default:
//            completion(.failure(EndPointError.unsupportedEndpoint(message: "Endpoint is not supported")))
//        }
//    }

///Use Endpoint.category for category VC with sources, and Endpoint.articles for list of articles with parameters
//    static func fetchArticles(endpoint: EndPoints, completion: @escaping (Result<[Article]>) -> Void) {
//        let articlesRequest = makeRequest(for: endpoint)
//        let task = urlSession.dataTask(with: articlesRequest) { data, response, error in
//            // Check for errors.
//            if let error = error {
//                return completion(Result.failure(error))
//            }
//            // Check to see if there is any data that was retrieved.
//            guard let data = data else {
//                return completion(Result.failure(EndPointError.noData(message: "Articles has no data")))
//            }
//            //decode data
//            guard let result = try? JSONDecoder().decode(ArticleList.self, from: data) else {
////                do { //data debugging
////                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]
////                    print(jsonResult)
////                } catch {
////                    print("Error deserializing JSON: \(error)")
////                }
//                return completion(Result.failure(EndPointError.couldNotParse(message: "Could not parse Articles")))
//            }
//            if result.status == "error" { //check if status has error
//                guard let errorMessage = result.message, let errorCode = result.code else { //check if theres an error message from the endpoint
//                    return completion(Result.failure(EndPointError.unknown()))
//                }
//                switch errorCode { //check if endpoint error is known
//                case "maximumResultsReached": //free acc allows to fetch 100 articles only
//                    return completion(Result.failure(EndPointError.maximumResultsReached()))
//                default:
//                    return completion(Result.failure(EndPointError.endpointError(message: "Endpoint Error \(errorCode): \(errorMessage)"))) //error message from endpoint
//                }
//            }
//            DispatchQueue.main.async {
//                totalCount = result.totalResults! //update total articles
//                //Ensure we are passing unique array articles. Article must conform to Hashable and Equatable
//                let uniqueArticles = Array(NSOrderedSet(array: result.articles!)) as? [Article]
//                completion(Result.success(uniqueArticles!))
//            }
//        }
//        task.resume()
//    }

//    static func fetchSources(completion: @escaping (Result<[Source]>) -> Void) {
//        let articlesRequest = makeRequest(for: .sources) //setup request as source
//        let task = urlSession.dataTask(with: articlesRequest) { data, response, error in
//            // Check for errors.
//            if let error = error {
//                return completion(Result.failure(error))
//            }
//            // Check to see if there is any data that was retrieved.
//            guard let data = data else {
//                return completion(Result.failure(EndPointError.noData(message: "Sources has no data")))
//            }
//            guard let result = try? JSONDecoder().decode(Sources.self, from: data) else {
//                return completion(Result.failure(EndPointError.couldNotParse(message: "Could not parse sources")))
//            }
//            if result.status != "ok" {
//                completion(Result.failure(EndPointError.endpointError(message: result.message ?? "Unknown endpoint error")))
//            }
//            let sources = result.sources
//            // Return the result with the completion handler.
//            DispatchQueue.main.async {
//                completion(Result.success(sources))
//            }
//        }
//        task.resume()
//    }

    // All the code we did before but cleaned up into their own methods
    static private func makeRequest(for endPoint: EndPoints) -> URLRequest {
        // grab the parameters from the endpoint and convert them into a string
        let stringParams = endPoint.paramsToString(parameters: parameters)
        // get the path of the endpoint
        let path = endPoint.getPath()
        // create the full url from the above variables
        let fullURL = URL(string: baseURL.appending("\(path)?\(stringParams)"))!
        print("Full path: \(fullURL)")
        // build the request
        var request = URLRequest(url: fullURL)
        let apiKey = ""
        request.allHTTPHeaderFields = endPoint.getHeaders(apiKey: apiKey)
        request.httpMethod = endPoint.getHTTPMethod()
        return request
    }
}
