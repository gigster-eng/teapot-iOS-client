//
//  UIImage+Resize.swift
//  Teapot
//
//  Created by Matthew Baker on 4/2/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit

extension UIImage {
  func scaleImageToSize(newWidth: CGFloat) -> UIImage {
    let oldWidth = self.size.width
    let scaleFactor = newWidth / oldWidth
    
    let newHeight = self.size.height * scaleFactor;
    let newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    self.drawInRect(CGRectMake(0, 0, newWidth, newHeight));
    let newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
  }
}
