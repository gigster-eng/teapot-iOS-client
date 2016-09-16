//
//  Message.swift
//  Teapot
//
//  Created by Matthew Baker on 3/26/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import Foundation

class Message {
  var content: String? = nil
  var sentAt: NSDate? = nil
  var read: Bool? = nil
  var sentByViewer: Bool? = nil
  
  func setFromJson(json: [String:AnyObject]) {
    content = json["content"] as? String
    if let sentAtNumber = json["sent_at"] as? NSNumber {
      sentAt = NSDate(timeIntervalSince1970: Double(sentAtNumber))
    }
    read = json["read"] as? Bool
    sentByViewer = json["sent_by_viewer"] as? Bool
  }
  
  func heightForContent(font: UIFont, width: CGFloat) -> CGFloat {
    let rect = NSString(string: content ?? "").boundingRectWithSize(CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
    let size = max(ceil(rect.height), 30)
    
    if size == 30 {
      return size
    }
    
    return size + 10
  }
}