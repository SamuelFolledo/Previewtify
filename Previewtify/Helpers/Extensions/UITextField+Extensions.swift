//
//  UITextField+Extensions.swift
//  StrepScan
//
//  Created by Samuel Folledo on 7/27/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit.UITextField

extension UITextField {
    func setPadding(left: CGFloat, right: CGFloat) {
        let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: left, height: frame.size.height))
        leftView = leftPadding
        leftViewMode = .always
        let rightPadding = UIView(frame: CGRect(x: 0, y: 0, width: right, height: frame.size.height))
        rightView = rightPadding
        rightViewMode = .always
    }
}
