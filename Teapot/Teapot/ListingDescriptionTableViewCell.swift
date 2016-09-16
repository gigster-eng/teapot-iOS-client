//
//  ListingDescriptionTableViewCell.swift
//  Teapot
//
//  Created by Matthew Baker on 3/26/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit

class ListingDescriptionTableViewCell: UITableViewCell {
  @IBOutlet weak var descriptionLabel: UILabel?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func configureWithItem(item: Item) {
    descriptionLabel?.text = item.itemDescription
  }
}
