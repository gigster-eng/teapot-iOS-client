//
//  UIView+Extensions.swift
//  Teapot
//
//  Created by Matthew Baker on 3/17/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import Foundation

extension UIView {
  func highestSuperview() -> UIView {
    var parent = self.superview
    while parent?.superview != nil {
      parent = parent?.superview
    }
    
    return parent ?? self
  }
}