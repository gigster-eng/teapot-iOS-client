//
//  AuthManager.swift
//  Receiptly
//
//  Created by Lin Xuan on 19/02/16.
//  Copyright © 2016 Receiptly. All rights reserved.
//

import UIKit

struct FacebookUser {
    var access_token: String
    var id:String
}

class AuthManager {

    
    static let sharedManager = AuthManager()
    
    var user: GIDGoogleUser?
    var fbUser:FacebookUser?
    
    
}