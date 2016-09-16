//
//  DesignableImage.swift
//  Teapot
//
//  Created by Matthew Baker on 12/21/15.
//  Copyright © 2015 Matthew Baker. All rights reserved.
//

import UIKit

@IBDesignable
class DesignableImage: UIImageView {
  override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
  }
  
  @IBInspectable var borderColor: UIColor = UIColor.clearColor() {
    didSet {
      layer.borderColor = borderColor.CGColor
    }
  }
  
  @IBInspectable var borderWidth: CGFloat = 0 {
    didSet {
      layer.borderWidth = borderWidth
    }
  }
  
  @IBInspectable var cornerRadius: CGFloat = 0 {
    didSet {
      layer.cornerRadius = cornerRadius
    }
  }
}
