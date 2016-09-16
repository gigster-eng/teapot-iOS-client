//
//  UIImage+FixOrientation.swift
//  Teapot
//
//  Created by Matthew Baker on 4/2/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import Foundation

extension UIImage {
  func fixOrientation() -> UIImage? {
    // No-op if the orientation is already correct
    if (self.imageOrientation == .Up) {
      return self
    }
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    var transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
    case .Down, .DownMirrored:
      transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height)
      transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
      break
      
    case .Left, .LeftMirrored:
      transform = CGAffineTransformTranslate(transform, self.size.width, 0)
      transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
      break
      
    case .Right, .RightMirrored:
      transform = CGAffineTransformTranslate(transform, 0, self.size.height)
      transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
      break
    case .Up, .UpMirrored:
      break
    }
    
    switch (self.imageOrientation) {
    case .UpMirrored, .DownMirrored:
      transform = CGAffineTransformTranslate(transform, self.size.width, 0)
      transform = CGAffineTransformScale(transform, -1, 1)
      break
      
    case .LeftMirrored, .RightMirrored:
      transform = CGAffineTransformTranslate(transform, self.size.height, 0)
      transform = CGAffineTransformScale(transform, -1, 1)
      break
    case .Up, .Down, .Left, .Right:
      break
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    let ctx = CGBitmapContextCreate(nil, Int(self.size.width), Int(self.size.height),
                                    CGImageGetBitsPerComponent(self.CGImage), 0,
                                    CGImageGetColorSpace(self.CGImage),
                                    CGImageGetBitmapInfo(self.CGImage).rawValue)
    CGContextConcatCTM(ctx, transform)
    switch (self.imageOrientation) {
    case .Left, .LeftMirrored, .Right, .RightMirrored:
      CGContextDrawImage(ctx, CGRectMake(0,0, self.size.height, self.size.width), self.CGImage)
      break
      
    default:
      CGContextDrawImage(ctx, CGRectMake(0,0, self.size.width, self.size.height), self.CGImage)
      break
    }
    
    // And now we just create a new UIImage from the drawing context
    if let cgimg = CGBitmapContextCreateImage(ctx) {
      let img = UIImage(CGImage: cgimg)
      return img
    }
    return nil
  }
}