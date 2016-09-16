//
//  AutocompleteResult.swift
//  Teapot
//
//  Created by Matthew Baker on 3/17/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit

import Foundation
import UIKit

class AutocompleteResult: UITableViewCell {
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func label() -> UILabel? {
    return viewWithTag(1) as? UILabel
  }
  
  func configure(text: String) {
    label()?.text = text
  }
  
}
