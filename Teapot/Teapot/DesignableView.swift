//
//  DesignableView.swift
//  Teapot
//
//  Created by Matthew Baker on 3/17/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit
import QuartzCore

@IBDesignable
class DesignableView: UIView {
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
  
  @IBInspectable var masksToBounds: Bool = false {
    didSet {
      layer.masksToBounds = masksToBounds
    }
  }
  
  @IBInspectable var clipsSubviews: Bool = false {
    didSet {
      clipsToBounds = clipsSubviews
    }
  }
  
  @IBInspectable var shadowWidth: CGFloat = 0.0 {
    didSet {
      layer.shadowOffset = CGSizeMake(shadowWidth, shadowHeight)
    }
  }
  
  @IBInspectable var shadowHeight: CGFloat = 0.0 {
    didSet {
      layer.shadowOffset = CGSizeMake(shadowWidth, shadowHeight)
    }
  }
  
  @IBInspectable var shadowRadius: CGFloat = 0.0 {
    didSet {
      layer.shadowRadius = shadowRadius
    }
  }
  
  @IBInspectable var shadowOpacity: Float = 0.0 {
    didSet {
      layer.shadowOpacity = shadowOpacity
    }
  }
}
