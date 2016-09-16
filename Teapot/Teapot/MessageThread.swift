//
//  MessageThread.swift
//  Teapot
//
//  Created by Matthew Baker on 3/26/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import Foundation

class MessageThread {
  var threadId: String? = nil
  var viewerUser: User? = nil
  var otherUser: User? = nil
  var listing: Item? = nil
  var messages: [Message] = []
  
  func setFromJson(json: [String:AnyObject]) {
    threadId = json["message_thread_id"] as! String?
    viewerUser = User()
    if let viewerJson = json["viewer_user_profile"] as? [String:AnyObject] {
      viewerUser?.setFromJson(viewerJson)
    }
    
    otherUser = User()
    if let otherJson = json["other_user_profile"] as? [String:AnyObject] {
      otherUser?.setFromJson(otherJson)
    }
    
    listing = Item()
    if let listingJson = json["listing"] as? [String:AnyObject] {
      listing?.setFromJson(listingJson)
    }
    
    messages = []
    if let messagesJson = json["messages"] as? [[String:AnyObject]] {
      for messageJson in messagesJson {
        let message = Message()
        message.setFromJson(messageJson)
        messages.append(message)
      }
    }
  }
}