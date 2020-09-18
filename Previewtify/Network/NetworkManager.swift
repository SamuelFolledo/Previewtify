//
//  NetworkManager.swift
//  Previewtify
//
//  Created by Samuel Folledo on 9/18/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import Foundation

//class NetworkManager {
//    //make it singleton
//    public static let shared = NetworkManager()
//    private init() {}
//    //properties
//    static let urlSession = URLSession.shared // shared singleton session object used to run tasks. Will be useful later
//    static private let baseURL = "https://newsapi.org/v2/"
//    static private let apiKey = PrivateKeys.newsApiKey.rawValue
//    static private var parameters: [String: String] = [kPAGE: "0", kPAGESIZE: "20"]
//    static var totalCount: Int = Int.max
//
/////Updates parameters
//    static func updateParameters(parameters: [String: String]) {
//        for parameter in parameters.compactMapValues({ $0 }) where parameter.value != "" { //compactMapValues removes nil values, and ensures it will not read "" values
//            self.parameters[parameter.key] = parameter.value
//        }
//    }
//
//    static func resetNetworkManager() { //reset totalCount and parameters
//        totalCount = Int.max
////        parameters = [kPAGE: "0", kPAGESIZE: "20"]
//    }
//
/////Function that calls fetchArticle or fetchSources depending on the endpoint
//    static func fetchNewsApi(endpoint: EndPoints, parameters: [String: String] = [:], completion: @escaping (Result<[Article]>) -> Void) {
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
//
/////Use Endpoint.category for category VC with sources, and Endpoint.articles for list of articles with parameters
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
//
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
//
//    // All the code we did before but cleaned up into their own methods
//    static private func makeRequest(for endPoint: EndPoints) -> URLRequest {
//        // grab the parameters from the endpoint and convert them into a string
//        let stringParams = endPoint.paramsToString(parameters: parameters)
//        // get the path of the endpoint
//        let path = endPoint.getPath()
//        // create the full url from the above variables
//        let fullURL = URL(string: baseURL.appending("\(path)?\(stringParams)"))!
//        print("Full path: \(fullURL)")
//        // build the request
//        var request = URLRequest(url: fullURL)
//        request.allHTTPHeaderFields = endPoint.getHeaders(apiKey: apiKey)
//        request.httpMethod = endPoint.getHTTPMethod()
//        return request
//    }
//}

