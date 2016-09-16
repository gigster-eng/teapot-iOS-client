//
//  ChatTableViewCell.swift
//  Teapot
//
//  Created by Matthew Baker on 3/26/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit

class OtherChatTableViewCell: UITableViewCell {
  @IBOutlet weak var userAvatar: DesignableImage?
  @IBOutlet weak var userFirstName: UILabel?
  @IBOutlet weak var chatMessage: UILabel?
  @IBOutlet weak var chatTimestamp: UILabel?
  @IBOutlet weak var chatMessageHeightConstraint: NSLayoutConstraint!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func configureWith(message: Message, fromUser: User, width: CGFloat) {
    if fromUser.id == ModelManager.sharedManager.getAppID() {
      userFirstName?.text = "You"
    } else {
      userFirstName?.text = fromUser.first_name
    }
    
    chatMessage?.text = message.content
    chatMessageHeightConstraint?.constant = message.heightForContent(chatMessage?.font ?? UIFont(name: "Lato", size: 14), width: width)
    
    userAvatar?.sd_cancelCurrentImageLoad()
    userAvatar?.image = nil
    if let url = NSURL(string: fromUser.profile_picture) {
      userAvatar?.sd_setImageWithURL(url)
    }
    
    if let sentAt = message.sentAt {
      let formatter = NSDateFormatter()
      formatter.AMSymbol = "am"
      formatter.PMSymbol = "pm"
      formatter.dateFormat = "h:mm a, MMMM d"
      
      chatTimestamp?.text = formatter.stringFromDate(sentAt) + daySuffix(sentAt)
    }
    
    contentView.layoutIfNeeded()
  }
  
  func daySuffix(date: NSDate) -> String {
    let calendar = NSCalendar.currentCalendar()
    let dayOfMonth = calendar.component(.Day, fromDate: date)
    return dayOfMonth.numberSuffix()
  }
}
