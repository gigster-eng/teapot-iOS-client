//
//  FriendTableViewCell.swift
//  Teapot
//
//  Created by Matthew Baker on 5/30/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit

protocol FriendTableViewCellDelegate {
  func detailTapped(user: User)
}

class FriendTableViewCell: UITableViewCell {
  
  @IBOutlet weak var userAvatar: DesignableImage?
  @IBOutlet weak var viewDetailsButton: UIButton?
  @IBOutlet weak var inviteButton: UIButton?
  @IBOutlet weak var firstNameLabel: UILabel?
  
  var delegate: FriendTableViewCellDelegate? = nil
  var user: User? = nil
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func setForUser(user: User) {
    self.user = user
    
    inviteButton?.hidden = false
    viewDetailsButton?.hidden = false
    
    if user.isAppUser == false {
      viewDetailsButton?.hidden = true
    } else {
      inviteButton?.hidden = true
    }
    
    if user.last_name == nil || user.last_name == "" {
      firstNameLabel?.text = user.name
    } else {
      firstNameLabel?.text = String(format: "%@ %@", user.first_name, user.last_name ?? "")
    }
    userAvatar?.sd_cancelCurrentImageLoad()
    userAvatar?.sd_setImageWithURL(NSURL(string: user.profile_picture))
  }
  
  @IBAction func buttonTapped(sender: AnyObject) {
    if let user = user {
      delegate?.detailTapped(user)
    }
  }
}
