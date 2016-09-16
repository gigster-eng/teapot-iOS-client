//
//  ListingConditionTableViewCell.swift
//  Teapot
//
//  Created by Matthew Baker on 3/26/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit

class ListingConditionTableViewCell: UITableViewCell {
  @IBOutlet weak var conditionLabel: UILabel?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func configureWithItem(item: Item) {
    conditionLabel?.text = item.condition
  }
  
}
