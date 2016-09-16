//
//  ProductSearchResult.swift
//  Teapot
//
//  Created by Matthew Baker on 3/20/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit

/*

{
"amazon_asin": <string>,
"amazon_url": <url>,
"sales_rank": <string>,
"small_image": <url>,
"medium_image": <url>,
"large_image": <url>,
"title": <string>,
"product_group": <string>,
"manufacturer": <string>,
"brand": <string>,
"price": <string>,
"category": <string>
}

*/

class ProductSearchResult {
  var amazonAsin: String?
  var amazonURL: NSURL?
  var averageRating: Double?
  var salesRank: Int?
  var smallImageURL: NSURL?
  var mediumImageURL: NSURL?
  var largeImageURL: NSURL?
  var title: String?
  var productGroup: String?
  var manufacturer: String?
  var numRatings: Int?
  var brand: String?
  var price: Double?
  var category: String?
  var secondaryImages: [NSURL] = []
  
  func setFromJson(json: [String:AnyObject]){
    amazonAsin = json["amazon_asin"] as? String
    amazonURL = NSURL(string: json["amazon_url"] as? String ?? "")
    averageRating = json["average_rating"] as? Double
    numRatings = json["num_ratings"] as? Int
    salesRank = Int(json["sales_rank"] as? String ?? "")
    smallImageURL = NSURL(string: json["small_image"] as? String ?? "")
    mediumImageURL = NSURL(string: json["medium_image"] as? String ?? "")
    largeImageURL = NSURL(string: json["large_image"] as? String ?? "")
    title = json["title"] as? String
    productGroup = json["product_group"] as? String
    manufacturer = json["manufacturer"] as? String
    brand = json["brand"] as? String
    if var priceStr = json["price"] as? String {
      if priceStr.characters.count > 0 && priceStr.characters.first == "$" {
        priceStr = String(priceStr.characters.dropFirst())
      }
      
      price = Double(priceStr)
    }
    if let secondaryImagesStrs = json["secondary_images"] as? [String] {
      for img in secondaryImagesStrs {
        if let url = NSURL(string: img) {
          secondaryImages.append(url)
        }
      }
    }
    
    category = json["category"] as? String
  }
  
  func widthForCategory(font: UIFont, height: CGFloat) -> CGFloat {
    return widthForString(category ?? "", font: font, height: height)
  }
  
  func widthForString(string: String, font: UIFont, height: CGFloat) -> CGFloat {
    let rect = NSString(string: string).boundingRectWithSize(CGSize(width: CGFloat(MAXFLOAT), height: height), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
    return ceil(rect.width)
  }
}