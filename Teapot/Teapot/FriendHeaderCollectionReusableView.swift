//
//  FriendHeaderCollectionReusableView.swift
//  Teapot
//
//  Created by Matthew Baker on 6/1/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit

class FriendHeaderCollectionReusableView: UICollectionReusableView {
  @IBOutlet weak var userAvatar: DesignableImage?
  @IBOutlet weak var connectionDegree: UILabel?
  @IBOutlet weak var joinedDateLabel: UILabel?
  @IBOutlet weak var locationLabel: UILabel?
  @IBOutlet weak var firstNameLabel: UILabel?
  @IBOutlet weak var friendsCollectionView: UICollectionView?
  @IBOutlet weak var friendsWithLabel: UILabel?
  @IBOutlet weak var postedByLabel: UILabel?
  @IBOutlet weak var connectionSectionHeight: NSLayoutConstraint?
  @IBOutlet weak var friendsContainer: UIView?
  
  var userFriends: [User] = []
  
  func configureWithUser(user: User) {
    userFriends = user.trustGraph?.commonFriends ?? []
    if user.trustGraph?.distance != 2 || user.trustGraph?.commonFriends?.count == 0 {
      connectionSectionHeight?.constant = 0
      friendsContainer?.hidden = true
    } else {
      connectionSectionHeight?.constant = 170
      friendsContainer?.hidden = false
    }
    
    friendsWithLabel?.text = String(format: "Connected to %@ (%ld)", user.first_name, userFriends.count)
    if user.trustGraph?.distance == 2 {
      friendsWithLabel?.text = String(format: "Friends with %@ (%ld)", user.first_name, userFriends.count)
    }
    
    postedByLabel?.text = String(format: "Posted by %@", user.first_name)
    friendsCollectionView?.reloadData()
    
    userAvatar?.sd_cancelCurrentImageLoad()
    userAvatar?.image = nil
    if let url = NSURL(string: user.profile_picture) {
      userAvatar?.sd_setImageWithURL(url)
    }
    
    firstNameLabel?.text = user.first_name

    let connectionDistance = user.trustGraph?.distance ?? 0
    connectionDegree?.hidden = connectionDistance == 0 || connectionDistance == 6
    connectionDegree?.text = String(format: "%ld%@", connectionDistance, connectionDistance.numberSuffix())
    
    if let date = user.registeredDate {
      let dateFormat = "MMMM yyyy"
      let formatter = NSDateFormatter()
      formatter.dateFormat = dateFormat
      
      let monthYearString = formatter.stringFromDate(date)
      joinedDateLabel?.text = String(format: "Joined: %@", monthYearString)
    }
    
    if let locationData = user.location {
      locationLabel?.text = String(format: "%@, %@", locationData.city, locationData.state)
    } else if let locationStr = user.locationStr {
      locationLabel?.text = locationStr
    }
    
    needsUpdateConstraints()
    layoutIfNeeded()
  }
}

extension FriendHeaderCollectionReusableView: UICollectionViewDelegate {
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
  }
}

extension FriendHeaderCollectionReusableView: UICollectionViewDataSource {
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return userFriends.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ConnectionCell", forIndexPath: indexPath) as! ListingFriendCollectionViewCell
    
    cell.configurWithUser(userFriends[indexPath.row])
    
    return cell
  }
}
