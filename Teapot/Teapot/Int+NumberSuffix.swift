//
//  Int+NumberSuffix.swift
//  Teapot
//
//  Created by Matthew Baker on 3/26/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import Foundation

extension Int {
  func numberSuffix() -> String {
    switch self {
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