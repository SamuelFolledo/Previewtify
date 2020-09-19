//
//  Defaults.swift
//  StrepScan
//
//  Created by Samuel Folledo on 8/19/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import Foundation
import FirebaseAuth

struct Defaults {
    private enum Keys {
        static let onboard = "onboard"
        static let cards = "cards"
        static let account = "account"
    }
    
    static var onboard: Bool {
        get { return UserDefaults.standard.bool(forKey: Keys.onboard) }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.onboard)
            UserDefaults.standard.synchronize()
        }
    }
    
    static var hasLoggedInOrCreatedAccount: Bool {
        get { return UserDefaults.standard.bool(forKey: Keys.account) }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.account)
            UserDefaults.standard.synchronize()
        }
    }
    
    //MARK: Methods
    
    ///use after logging out 
    static func _removeUser(_ removeFromUserDefaults: Bool = false) {
        guard let userType = Defaults.valueOfUserType() else { return }
        if removeFromUserDefaults {
            switch userType {
            case .Patient:
                UserDefaults.standard.removeObject(forKey: Constants.patientUser)
            case .Doctor:
                UserDefaults.standard.removeObject(forKey: Constants.doctorUser)
            }
            //clear everything in UserDefaults
            UserDefaults.standard.deleteAllKeys(exemptedKeys: ["onboard"])
        }
    }
    
    ///save user type into UserDefaults
    static func setUserType(_ accountType: UserType, writeToUserDefaults: Bool = false) {
        if writeToUserDefaults {
            UserDefaults.standard.set(accountType.rawValue, forKey: Constants.userType)
            UserDefaults.standard.synchronize()
        }
    }
    
    ///get value of user type from UserDefaults
    static func valueOfUserType() -> UserType? {
        guard let userTypeString = UserDefaults.standard.string(forKey: Constants.userType) else { return nil }
        guard let userType = UserType(rawValue: userTypeString) else { return nil }
        return userType
    }
}
