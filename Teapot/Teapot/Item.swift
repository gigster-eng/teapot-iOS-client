import UIKit
import RealmSwift

struct Location {
    var city: String
    var country: String
    var latitude: NSNumber
    var longitude: NSNumber
    var state: String
    var zip: String
}

class Item: Object {
    
    var listingId: String? = nil
    var title: String!
    var itemDescription: String!
    var imageURLs: String?
    var imageURL: String? {
      get {
        return imageURLArray().first
      }
    }
  
    override static func primaryKey() -> String? {
      return "listingId"
    }
  
    var category: String!
    var createdAt: NSDate!
    var updatedAt: NSDate!
    var user: User!
    var price: Double!
    var location: Location!
    var condition: String!
    var amazonAsin: String?
    var soldAt: NSDate?
    var takenDownAt: NSDate?
  
    // Not mapped, display only
    var secondaryImages: [NSURL] = []
  
    override class func ignoredProperties() -> [String] {
        return ["secondaryImages", "user"]
    }
  
    func widthForLocation(font: UIFont, height: CGFloat) -> CGFloat {
        return widthForString("\(location.city), \(location.state)", font: font, height: height)
    }

    func widthForCategory(font: UIFont, height: CGFloat) -> CGFloat {
        return widthForString(category, font: font, height: height)
    }

    func widthForString(string: String, font: UIFont, height: CGFloat) -> CGFloat {
        let rect = NSString(string: string).boundingRectWithSize(CGSize(width: CGFloat(MAXFLOAT), height: height), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return ceil(rect.width)
    }
    
    func heightForTitle(font: UIFont, width: CGFloat) -> CGFloat {
        let rect = NSString(string: title).boundingRectWithSize(CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return ceil(rect.height)
    }
  
    func imageURLArray() -> [String] {
        return imageURLs?.componentsSeparatedByString(",") ?? []
    }
    
    static func getDummyItems() -> [Item] {
        
        let dummyTitle = [
            "Best Crib Ever Super Super Super Super Long Edition",
            "Best Crib Ever Girl Edition",
            "SuperSoft shoes",
            "Todler Mattress",
            "Best Crib Ever",
            "Nice Tea",
            "Imba Shoes",
            "Crazy 5",
            "kkkk",
        ]
        
        var items = [Item]()
        for index in 0...8 {
            let item = Item()
            item.title = dummyTitle[index]
            items.append(item)
        }
        
        return items
    }
    
    convenience init(json: [String:AnyObject]) {
        self.init()
        setFromJson(json)
    }
    
    func setFromJson(json: [String:AnyObject]) {
        print(json)
        listingId = json["listing_id"] as? String
        title = json["title"] as! String
        itemDescription = json["description"] as? String ?? ""
        price = json["price"] as! Double
        category = json["category"] as! String
        condition = json["condition"] as? String ?? ""
        amazonAsin = json["amazon_asin"] as? String
        let imageURLsFromServer = json["photo_filenames"] as? [String] ?? []
        imageURLs = imageURLsFromServer.joinWithSeparator(",")
      
        if let soldAtNumber = json["sold_at"] as? NSNumber {
          soldAt = NSDate(timeIntervalSince1970: Double(soldAtNumber))
        }
      
        if let takenDownAtNumber = json["taken_down_at"] as? NSNumber {
          takenDownAt = NSDate(timeIntervalSince1970: Double(takenDownAtNumber))
        }
      
        if let locationJson = json["location"] as? [String:AnyObject] {
            location = Location(city: locationJson["city"] as? String ?? "", country: locationJson["country"] as! String, latitude: locationJson["latitude"] as! NSNumber, longitude: locationJson["longitude"] as! NSNumber, state: locationJson["state"] as? String ?? "", zip: locationJson["zip"] as? String ?? "")
        }
        createdAt = NSDate(timeIntervalSince1970: Double(json["created_at"] as! NSNumber))
        updatedAt = NSDate(timeIntervalSince1970: Double(json["updated_at"] as! NSNumber))
        
        if let userJson = json["poster_profile"] as? [String:AnyObject] {
            user = User()
            user?.setFromJson(userJson)
        }
    }
  
    func getJson() -> [String:AnyObject] {
      var data: [String:AnyObject] = [
        "title": title,
        "description": itemDescription,
        "price": price,
        "category": category,
        "condition": condition,
        "amazon_asin": amazonAsin ?? "",
        "photo_filenames": imageURLArray(),
      ]
      
      if listingId != nil {
        data["listing_id"] = listingId!
      }
      
      if soldAt != nil {
        data["sold_at"] = soldAt!.timeIntervalSince1970
      } else {
        data["sold_at"] = NSNull()
      }
      
      if takenDownAt != nil {
        data["taken_down_at"] = takenDownAt!.timeIntervalSince1970
      } else {
        data["taken_down_at"] = NSNull()
      }
      
      return data
    }
  
    func setFromProductResult(result: ProductSearchResult) {
      title = result.title
      category = result.category
      amazonAsin = result.amazonAsin
      secondaryImages = result.secondaryImages
      if result.largeImageURL != nil {
        secondaryImages.insert(result.largeImageURL!, atIndex: 0)
      }
    }
  
    func formattedDate() -> String {
      if createdAt != nil {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM d"
      
        let dateString = formatter.stringFromDate(createdAt) + daySuffix(createdAt)
        return dateString
      }
    
      return ""
    }
  
    func daySuffix(date: NSDate) -> String {
      let calendar = NSCalendar.currentCalendar()
      let dayOfMonth = calendar.component(.Day, fromDate: date)
      return dayOfMonth.numberSuffix()
    }
}
