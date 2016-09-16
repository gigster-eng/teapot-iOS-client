//
//  User.swift
//  Teapot
//
//  Created by Chris on 2/29/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import Foundation
import RealmSwift

struct TrustGraph {
  var trustScore: Double?
  var distance: Int?
  var commonFriends: [User]?
}

class User: Object {
    dynamic var first_name = ""
    dynamic var id = ""
    dynamic var last_name:String? = ""
    dynamic var name: String? = ""
    dynamic var email:String?
    dynamic var profile_picture = ""
    var isAppUser: Bool? = nil
    let listings = List<Item>()
    var location: Location? = nil
    var locationStr: String?
    var trustGraph: TrustGraph? = nil
    var registeredDate: NSDate?
  
    static var currentUser: User? {
        return try! Realm().objects(User).filter("id = %@", ModelManager.sharedManager.getAppID()).first
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func setFromJson(json: [String:AnyObject]){
        first_name = json["first_name"] as? String ?? ""
        id = json["id"] as! String
        last_name = json["last_name"] as? String
        name = json["name"] as? String
        profile_picture = json["profile_picture"] as! String
        email = json["email"] as? String
        isAppUser = json["is_app_user"] as? Bool
      
        if let createdAt = json["created_at"] as? NSNumber {
          registeredDate = NSDate(timeIntervalSince1970: Double(createdAt))
        }
      
        if let locationJson = json["location"] as? [String:AnyObject] {
          location = Location(city: locationJson["city"] as? String ?? "", country: locationJson["country"] as! String, latitude: locationJson["latitude"] as! NSNumber, longitude: locationJson["longitude"] as! NSNumber, state: locationJson["state"] as? String ?? "", zip: locationJson["zip"] as? String ?? "")
        } else if let locationString = json["location"] as? String {
          locationStr = locationString
        }
      
        if let trustJson = json["trust_graph"] as? [String:AnyObject] {
          let trustScore = trustJson["trust_score"] as? Double
          let distance = trustJson["distance"] as? Int
          var commonFriends: [User] = []
          if let commonFriendsJson = trustJson["common_friends"] as? [[String:AnyObject]] {
            for friendJson in commonFriendsJson {
              let friend = User()
              friend.setFromJson(friendJson)
              commonFriends.append(friend)
            }
          }
          trustGraph = TrustGraph(trustScore: trustScore, distance: distance, commonFriends: commonFriends)
        }
      
        let listingsList = json["listings"] as? [[String:AnyObject]] ?? []
        listings.removeAll()
        
        for item in listingsList {
            let listing = Item()
            listing.setFromJson(item)
            listings.append(listing)
        }
    }

}