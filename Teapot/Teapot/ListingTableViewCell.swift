//
//  ListingTableViewCell.swift
//  Teapot
//
//  Created by Matthew Baker on 3/20/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit

class ListingTableViewCell: UITableViewCell {
  
  @IBOutlet weak var itemImage: UIImageView!
  @IBOutlet weak var date: UILabel?
  @IBOutlet weak var titleLabel: UILabel?
  @IBOutlet weak var itemTypeLabel: UILabel?
  @IBOutlet weak var itemTypeView: DesignableView?
  @IBOutlet weak var categoryWidthConstraint: NSLayoutConstraint?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    
    itemTypeLabel?.backgroundColor = UIColor.kitBlue()
    itemTypeLabel?.layer.cornerRadius = 5
    itemTypeLabel?.clipsToBounds = true
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func setFromItem(item: Item) {
    titleLabel?.text = item.title
    if let url = NSURL(string: item.imageURL ?? "") {
      itemImage?.sd_setImageWithURL(url)
    }
    itemTypeLabel?.text = item.category
    
    let font = UIFont(name: "Lato", size: 8)!
    let categoryWidth = item.widthForCategory(font, height: 13)
    categoryWidthConstraint?.constant = categoryWidth + 10
    
    date?.text = item.formattedDate()
    contentView.layoutIfNeeded()
  }
  
  func daySuffix(date: NSDate) -> String {
    let calendar = NSCalendar.currentCalendar()
    let dayOfMonth = calendar.component(.Day, fromDate: date)
    switch dayOfMonth {
    case 1: fallthrough
    case 21: fallthrough
    case 31: return "st"
    case 2: fallthrough
    case 22: return "nd"
    case 3: fallthrough
    case 23: return "rd"
    default: return "th"
    }
  }
}
