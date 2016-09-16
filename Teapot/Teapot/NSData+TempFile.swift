//
//  NSData+TempFile.swift
//  Teapot
//
//  Created by Matthew Baker on 3/20/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import Foundation

extension NSData {
  func writeToTempfile(fileExtension: String?) -> NSURL? {
    return writeToTempfile("", fileExtension: fileExtension)
  }
  
  func writeToTempfile(prefix: String, fileExtension: String?) -> NSURL? {
    let guid = prefix + (NSProcessInfo.processInfo().globallyUniqueString as String)
    if let filename = (guid as NSString).stringByAppendingPathExtension(fileExtension ?? "dat") {
      let filepath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(filename)
      if self.writeToFile(filepath, atomically: false) {
        return NSURL(fileURLWithPath: filepath)
      }
    }
    return nil
  }
}