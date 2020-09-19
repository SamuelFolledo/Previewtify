//
//  HomeController.swift
//  Previewtify
//
//  Created by Samuel Folledo on 9/18/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit

class HomeController: UIViewController {
    
    //MARK: Properties
    
    //MARK: Views
    
    //MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        NetworkManager.refreshAcessToken { (result) in
            switch result {
            case .failure(let error):
                print("Error refreshing token \(error.localizedDescription)")
            case .success(let spotifyAuth):
                print("REFRESHED ACCESS TOKEN \(spotifyAuth.accessToken)\nrefresh token= \(spotifyAuth.refreshToken)")
            }
        }
    }
    
    //MARK: Private Methods
    
    fileprivate func setupViews() {
        setupBackground()
    }
    
    fileprivate func setupBackground() {
        title = "Home"
        view.backgroundColor = .systemBackground
    }
    
    //MARK: Helpers
}

//MARK: Extensions


