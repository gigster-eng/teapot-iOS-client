//
//  ListingTitleTableViewCell.swift
//  Teapot
//
//  Created by Matthew Baker on 3/26/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit

class ListingTitleTableViewCell: UITableViewCell {
  @IBOutlet weak var itemTitle: UILabel?
  @IBOutlet weak var itemPrice: UILabel?
  @IBOutlet weak var itemCategory: UILabel?
  @IBOutlet weak var itemCategoryWidthConstraint: NSLayoutConstraint?
  @IBOutlet weak var listingDate: UILabel?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func configureFromItem(item: Item) {
    itemTitle?.text = item.title
    itemPrice?.text = item.price == 0 ? "FREE" : String(format: "$%.0f", item.price)
    itemCategory?.text = item.category
    listingDate?.text = item.formattedDate()
    
    let font = UIFont(name: "Lato", size: 8)!
    itemCategoryWidthConstraint?.constant = item.widthForCategory(font, height: 13.0) + 10
    contentView.layoutIfNeeded()
  }
  
}
