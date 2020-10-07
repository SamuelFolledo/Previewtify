//
//  PlayerView.swift
//  Previewtify
//
//  Created by Samuel Folledo on 10/7/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit
import Spartan

class PlayerView: UIView {
    
    //MARK: Properties
    
    var track: Track?
    
    //MARK: Views
    
    
    //MARK: Initializers
    init(track: Track) {
        self.track = track
        self.init()
        constraintViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Methods
    
    fileprivate func constraintViews() {
        
    }
}
