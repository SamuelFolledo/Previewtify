//
//  UIImage+Extensions.swift
//  StrepScan
//
//  Created by Samuel Folledo on 8/30/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit.UIImage

extension UIImage {
    
    ///convert image to data (conform UIImage to Encodable)
    func base64() -> String? {
        let imageData: Data = self.pngData()!
        return imageData.base64EncodedString()
    }
}
