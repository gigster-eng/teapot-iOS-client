//
//  ListingImageCollectionViewCell.swift
//  Teapot
//
//  Created by Matthew Baker on 3/26/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit

class ListingImageCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var imageView: UIImageView?
  @IBOutlet weak var photoCount: UILabel?
  @IBOutlet weak var photoCredit: UILabel?
  
  func configureFor(urlString: String, numPhoto: Int, totalPhotos: Int, isAmazon: Bool) {
    photoCredit?.hidden = isAmazon == false
    photoCount?.text = String(format: "%ld/%ld", numPhoto, totalPhotos)
    
    imageView?.sd_cancelCurrentImageLoad()
    imageView?.image = nil
    if let url = NSURL(string: urlString) {
      imageView?.sd_setImageWithURL(url)
    }
  }
}
