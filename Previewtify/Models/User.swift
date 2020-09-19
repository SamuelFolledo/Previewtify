//
//  User.swift
//  Previewtify
//
//  Created by Samuel Folledo on 9/19/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit
import Spartan

struct User: Codable {
    
    private(set) var name: String
    private(set) var email: String?
    private(set) var userId: String
    private(set) var imageUrl: String?
    private(set) var product: String
    private(set) var type: String
    private(set) var uri: String
    private(set) var country: String?
    private(set) var externalUrl: String?
    private(set) var href: String?
    
    //MARK: Singleton
    private static var _current: User?
    
    static var current: User? {
        // Check if current user (tenant) exist
        if let currentUser = _current {
            return currentUser
        } else {
            // Check if the user was saved in UserDefaults. If not, return nil
            guard let user = UserDefaults.standard.getStruct(User.self, forKey: Constants.currentUser) else { return nil }
            _current = user
            return user
        }
    }
    
    //MARK: Initializers
    
    init(user: PrivateUser) {
        self.name = user.displayName!
        self.email = user.email
        self.userId = user.id as! String
        self.imageUrl = user.images?.first?.url
        self.product = user.product!
        self.type = user.type
        self.uri = user.uri
        self.country = user.country
        self.externalUrl = user.externalUrls["spotify"]
        self.href = user.href
    }
}

// MARK: - Static Methods
extension User {
    static func setCurrent(_ user: User, writeToUserDefaults: Bool = false) {
        // Save user's information in UserDefaults excluding passwords and sensitive (private) info
        if writeToUserDefaults {
            UserDefaults.standard.setStruct(user, forKey: Constants.currentUser)
        }
        _current = user
    }
    
    static func removeCurrent(_ removeFromUserDefaults: Bool = false) {
        if removeFromUserDefaults {
            Defaults._removeUser(true)
        }
        _current = nil
    }
}

