//
//  ListingOwnerTableViewCell.swift
//  Teapot
//
//  Created by Matthew Baker on 3/26/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit

protocol ListingOwnerTableViewCellDelegate {
  func listingOwnerTableViewCellTapped(user: User)
}

class ListingOwnerTableViewCell: UITableViewCell {
  @IBOutlet weak var avatar: DesignableImage?
  @IBOutlet weak var connectionDegree: UILabel?
  @IBOutlet weak var joinedDate: UILabel?
  @IBOutlet weak var location: UILabel?
  @IBOutlet weak var firstName: UILabel?
  
  private var user: User? = nil
  private var tapGesture: UITapGestureRecognizer? = nil
  
  var delegate: ListingOwnerTableViewCellDelegate? = nil
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func configureWithUser(user: User) {
    self.user = user
    
    avatar?.sd_cancelCurrentImageLoad()
    avatar?.image = nil
    if let url = NSURL(string: user.profile_picture) {
      avatar?.sd_setImageWithURL(url)
    }
    
    if let tapGesture = tapGesture {
      self.removeGestureRecognizer(tapGesture)
    }
    tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileTapped))
    self.addGestureRecognizer(tapGesture!)
    
    let connectionDistance = user.trustGraph?.distance ?? 0
    connectionDegree?.hidden = connectionDistance == 0 || connectionDistance == 6
    connectionDegree?.text = String(format: "%ld%@", connectionDistance, connectionDistance.numberSuffix())
    
    if let date = user.registeredDate {
      let dateFormat = "MMMM yyyy"
      let formatter = NSDateFormatter()
      formatter.dateFormat = dateFormat
      
      let monthYearString = formatter.stringFromDate(date)
      joinedDate?.text = String(format: "Joined: %@", monthYearString)
    }
    
    if let locationData = user.location {
      location?.text = String(format: "%@, %@", locationData.city, locationData.state)
    } else if let locationStr = user.locationStr {
      location?.text = locationStr
    }
    
    firstName?.text = user.first_name
  }
  
  func profileTapped() {
    if let user = user {
      delegate?.listingOwnerTableViewCellTapped(user)
    }
  }
}
