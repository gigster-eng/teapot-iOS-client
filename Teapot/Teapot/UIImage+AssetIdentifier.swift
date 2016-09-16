//
//  UIImage+AssetIdentifier.swift
//  Envested
//
//  Created by Lin Gang Xuan on 16/01/16.
//  Copyright © 2016 Envested. All rights reserved.
//

import UIKit

extension UIImage {
    enum AssetIdentifier: String {

        case TutorialImage1 = "intro1"
        case TutorialImage2 = "intro2"
        case TutorialImage3 = "intro3"
        
        case menu_browse_active = "menu_browse_active"
        case menu_browse = "menu_browse"
        
        case menu_friends_active = "menu_friends_active"
        case menu_friends = "menu_friends"

        case menu_messages_active = "menu_messages_active"
        case menu_messages = "menu_messages"

        case menu_profile_active = "menu_profile_active"
        case menu_profile = "menu_profile"

        case menu_sell_active = "menu_sell_active"
        case menu_sell = "menu_sell"

    }
    
    convenience init!(assetIdentifier: AssetIdentifier) {
        self.init(named: assetIdentifier.rawValue)
    }
}