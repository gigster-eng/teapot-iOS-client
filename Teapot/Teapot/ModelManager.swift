//
//  ModelManager.swift
//  Goalzu
//
//  Created by Lin Gang Xuan on 28/09/15.
//  Copyright © 2015 Goalzu. All rights reserved.
//

import UIKit
import RealmSwift

class ModelManager: NSObject {
    static let sharedManager = ModelManager()
        
    func setAppID(id: String) {
        print(id)
        UDWrapper.setString(ProjConstants.id, value: id)
    }
    
    func getAppID() -> String {
        return UDWrapper.getString(ProjConstants.id) ?? ""
    }
        
    func updateUser(response: [String: AnyObject]) {
        print(response)
        let user = User()
        user.setFromJson(response)
        
        if let id = response["id"] as? String {
            print(id)
            user.id = id
            ModelManager.sharedManager.setAppID(String(id))
        }
        

        do {
            let realm = try Realm()
            try realm.write {
                realm.add(user,update: true)
            }
        } catch {
            print("realm error \(error)")
        }
    }
}
