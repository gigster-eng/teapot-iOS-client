//
//  UITableViewCell+Extension.swift
//  Envested
//
//  Created by Lin Gang Xuan on 30/12/15.
//  Copyright © 2015 Envested. All rights reserved.
//

import Foundation

extension UITextField {
    func applyPlaceholderAttributedString(string: String, color: UIColor) {
        let str = NSAttributedString(string: string, attributes: [NSForegroundColorAttributeName:color])
        attributedPlaceholder = str
    }
    
    func applyPasswordStyle() {
        keyboardType = .Default
        secureTextEntry = true
    }
    
    func applyEmailStyle() {
        keyboardType = .EmailAddress
        secureTextEntry = false
    }
    
    func applyNormalStyle() {
        keyboardType = .Default
        secureTextEntry = false
    }
}