//
//  MessageCreationRequest.swift
//  Teapot
//
//  Created by Matthew Baker on 3/26/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import Foundation

class MessageCreationRequest {
  func getJson(content: String, recipientId: String, listingId: String) -> [String:String] {
    return [
      "content": content,
      "app": AppConfiguration.appId,
      "sender_person_id": ModelManager.sharedManager.getAppID(),
      "recipient_person_id": recipientId,
      "listing_id": listingId
    ]
  }
}