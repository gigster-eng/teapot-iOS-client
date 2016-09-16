//
//  ChooseImageCollectionViewCell.swift
//  Teapot
//
//  Created by Matthew Baker on 3/18/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit

class ChooseImageCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var image: DesignableImage?
  @IBOutlet weak var selectedIndicator: DesignableImage?
  
  override var selected: Bool {
    didSet {
      selectedIndicator?.hidden = selected == false
    }
  }
}
