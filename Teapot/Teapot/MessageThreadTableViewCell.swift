//
//  MessageThreadTableViewCell.swift
//  Teapot
//
//  Created by Matthew Baker on 3/30/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit

class MessageThreadTableViewCell: UITableViewCell {
  @IBOutlet weak var userAvatar: DesignableImage?
  @IBOutlet weak var userSeparation: UILabel?
  @IBOutlet weak var userFirstName: UILabel?
  @IBOutlet weak var messagePreview: UILabel?
  @IBOutlet weak var unreadCountLabel: UILabel?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func configureWithMessageThread(thread: MessageThread) {
    userAvatar?.sd_cancelCurrentImageLoad()
    userAvatar?.image = nil
    
    if let url = NSURL(string: thread.otherUser?.profile_picture ?? "") {
      userAvatar?.sd_setImageWithURL(url)
    }
    
    if thread.otherUser?.trustGraph?.distance == nil || thread.otherUser?.trustGraph?.distance == 0 || thread.otherUser?.trustGraph?.distance == 6 {
      userSeparation?.hidden = true
    } else {
      userSeparation?.hidden = false
      userSeparation?.text = String(format: "%ld%@", (thread.otherUser?.trustGraph?.distance!)!, (thread.otherUser?.trustGraph?.distance!.numberSuffix())!)
    }
    
    userFirstName?.text = thread.otherUser?.first_name
    
    var unreadCount = 0
    var latest: Message? = nil
    for message in thread.messages {
      if message.sentByViewer == true {
        continue
      }
      
      if message.read == false {
        unreadCount += 1
      }
      
      if latest == nil {
        latest = message
      } else if latest?.sentAt != nil && message.sentAt != nil {
        if latest!.sentAt!.timeIntervalSince1970 < message.sentAt!.timeIntervalSince1970 {
          latest = message
        }
      }
    }
    
    if unreadCount == 0 {
      unreadCountLabel?.hidden = true
      userFirstName?.textColor = UIColor.kitBlack66()
    } else {
      unreadCountLabel?.hidden = false
      unreadCountLabel?.text = String(format: "(%ld)", unreadCount)
      userFirstName?.textColor = UIColor.kitGreen()
    }
    
    if latest == nil {
      messagePreview?.hidden = true
    } else {
      messagePreview?.hidden = false
      messagePreview?.text = latest?.content ?? ""
    }
  }
}
