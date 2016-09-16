//
//  ListingFriendCollectionViewCell.swift
//  Teapot
//
//  Created by Matthew Baker on 3/26/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit

class ListingFriendCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var avatar: DesignableImage?
  @IBOutlet weak var firstName: UILabel!
  
  
  func configurWithUser(user: User) {
    avatar?.sd_cancelCurrentImageLoad()
    avatar?.image = nil
    if let url = NSURL(string: user.profile_picture) {
      avatar?.sd_setImageWithURL(url)
    }
    
    firstName?.text = user.first_name
  }
}
