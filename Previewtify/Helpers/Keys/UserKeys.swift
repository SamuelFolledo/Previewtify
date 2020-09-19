//
//  UserKeys.swift
//  StrepScan
//
//  Created by Samuel Folledo on 8/19/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import Foundation

struct UsersKeys {
    
    ///keys for all Collections in the database
    struct Collection {
        static let Users: String = "Users"
        static let UserType: String = "UserType"
        static let ThroatScan: String = "ThroatScan"
    }
    
    ///keys for all User properties
    struct UserInfo {
        static let email: String = "email"
        static let firstName: String = "firstName"
        static let lastName: String = "lastName"
        static let userId: String = "userId"
        static let userType: String = "userType"
        static let throatScans: String = "throatScans"
        static let photoUrl: String = "photoUrl"
    }
    
    ///keys for all UserType
    struct UserType {
        static let Patient: String = "Patient"
        static let Doctor: String = "Doctor"
    }
}
