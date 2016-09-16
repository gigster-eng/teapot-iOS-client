//
//  SellSearchResultTableViewCell.swift
//  Teapot
//
//  Created by Matthew Baker on 3/18/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit

class SellSearchResultTableViewCell: UITableViewCell {
  
  @IBOutlet weak var titleLabel: UILabel?
  @IBOutlet weak var itemTypeLabel: UILabel?
  @IBOutlet weak var itemImage: UIImageView?
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
  
  func setFromProductSearchResult(item: ProductSearchResult) {
    titleLabel?.text = item.title
    if let url = item.mediumImageURL {
      itemImage?.sd_setImageWithURL(url)
    }
    itemTypeLabel?.text = item.category
    
    let font = UIFont(name: "Lato", size: 8)!
    let categoryWidth = item.widthForCategory(font, height: 13)
    categoryWidthConstraint?.constant = categoryWidth + 10
    contentView.layoutIfNeeded()
  }
  
}
