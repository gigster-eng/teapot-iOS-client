//
//  AWSS3Manager.swift
//  Teapot
//
//  Created by Matthew Baker on 3/20/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import Foundation
import AWSS3

public typealias FileUploadCallbackBlock = (NSError?, String?) -> Void

class AWSS3Manager {
  func uploadFile(url: NSURL, callback: FileUploadCallbackBlock) {
    let uploadRequest = AWSS3TransferManagerUploadRequest()
    uploadRequest.bucket = AppConfiguration.ProductFilesBucket
    
    if let filename = url.lastPathComponent {
      uploadRequest.key = filename
      uploadRequest.body = url
      if filename.hasSuffix(".png") {
        uploadRequest.contentType = "image/png"
      }
      
      let transferManager = AWSS3TransferManager.defaultS3TransferManager()
      transferManager.upload(uploadRequest).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: {(task) -> AnyObject? in
        if task.error != nil {
          callback(task.error, nil)
          return nil
        }
        
        if task.result != nil {
          callback(nil, uploadRequest.key)
          return nil
        }
        
        callback(NSError(domain: "An unknown error occurred", code: 0, userInfo: nil), nil)
        return nil
        })
    }
  }
}