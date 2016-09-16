//
//  ListingDetailsViewController.swift
//  Teapot
//
//  Created by Matthew Baker on 3/24/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit
import MapKit
import MBProgressHUD
import Branch

class SellerListingDetailsViewController: UIViewController {
  var item: Item = Item()
  var userFriends: [User] = []
  var amazonItem: ProductSearchResult? = nil
  var conditions: [String] = []
  var categories: [String] = []
  
  @IBOutlet weak var tableView: UITableView?
  @IBOutlet weak var imageCollectionView: UICollectionView?
  @IBOutlet weak var scrollView: UIScrollView?
  @IBOutlet weak var mapView: MKMapView?
  @IBOutlet weak var markAsSoldButton: DesignableButton?
  @IBOutlet weak var removeItemButton: DesignableButton?
  @IBOutlet weak var shareButton: DesignableButton?
  @IBOutlet weak var repostButton: DesignableButton?
  
  class Constants {
    static let TitleCellIdentifier = "Cell1"
    static let UserCellIdentifier = "Cell2"
    static let DescriptionCellIdentifier = "Cell3"
    static let ConditionCellIdentifier = "Cell4"
    static let ImageCollectionViewCellIdentifier = "ImageCollectionViewCell"
    static let EditListingSegueIdentifier = "EditListingSegue"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    title = item.title
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    scrollView?.contentSize = CGSizeMake(view.frame.size.width, 660)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.navigationBar.applyTheme(.Small)
    
    if item.location != nil {
      let location = CLLocation(latitude: item.location.latitude as CLLocationDegrees, longitude: item.location.longitude as CLLocationDegrees)
      
      addRadiusCircle(location)
    }
    
    updateActionItemStates()
    tableView?.reloadData()
    imageCollectionView?.reloadData()
    
    Connection(configuration: nil).getSettings({[weak self] (response, error) in
      if error != nil {
        print(error.localizedDescription)
        return
      }
      
      guard let settings = response as? [String:AnyObject] else {
        print("Could not parse settings response into settings")
        return
      }
      guard let selling = settings["selling"] as? [String:AnyObject] else {
        print("Could not parse settings response into settings")
        return
      }
      
      self?.conditions = (selling["conditions"] as? [String] ?? [])
      self?.categories = (selling["categories"] as? [String] ?? [])
      })
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    navigationController?.navigationBar.applyTheme(.Normal)
  }
  
  func updateActionItemStates() {
    if item.soldAt != nil || item.takenDownAt != nil {
      repostButton?.hidden = false
    }
    else {
      repostButton?.hidden = true
    }
    markAsSoldButton?.hidden = repostButton?.hidden == false
    removeItemButton?.hidden = repostButton?.hidden == false
    shareButton?.hidden = repostButton?.hidden == false
  }
  
  @IBAction func markAsSoldTapped(sender: AnyObject) {
    item.soldAt = NSDate()
    updateItem()
  }
  
  @IBAction func removeItemTapped(sender: AnyObject) {
    item.takenDownAt = NSDate()
    updateItem()
  }
  
  @IBAction func shareTapped(sender: AnyObject) {
    let branchUniversalObject: BranchUniversalObject = BranchUniversalObject(canonicalIdentifier: item.listingId!)
    branchUniversalObject.title = item.title
    branchUniversalObject.contentDescription = item.itemDescription
    branchUniversalObject.imageUrl = item.imageURL
    
    let linkProperties: BranchLinkProperties = BranchLinkProperties()
    linkProperties.feature = "sharing"
    linkProperties.addControlParam("listingId", withValue: item.listingId!)
    
    branchUniversalObject.getShortUrlWithLinkProperties(linkProperties,  andCallback: {[weak self] (url: String?, error: NSError?) -> Void in
      if error == nil {
        print(String(format: "got my Branch link to share: %@", url ?? ""))
        
        let string = "I found this on Teapot and thought you might like it"
        let activityItems = [string, url!]
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        activityViewController.modalTransitionStyle = .CoverVertical
        
        dispatch_async(dispatch_get_main_queue(), {
          self?.presentViewController(activityViewController, animated: true, completion: nil)
        })
      }
    })
  }
  
  @IBAction func repostTapped(sender: AnyObject) {
    item.soldAt = nil
    item.takenDownAt = nil
    updateItem()
  }
  
  func updateItem() {
    MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    
    // POST item
    let params:[String:AnyObject] = [
      "app": AppConfiguration.appId,
      "listing": item.getJson(),
      "creator_id": User.currentUser?.id ?? ""
    ]
    
    Connection(configuration: nil).createUpdateListing(params) {[weak self] response, error in
      if let actualSelf = self {
        MBProgressHUD.hideHUDForView(actualSelf.view, animated: true)
        
        if error != nil {
          actualSelf.showOKAlertView("Error", message: "Oops, something went wrong. Please give us a few minutes to fix the problem.")
          return
        }
        
        guard let listingData = response as? [String:AnyObject] else {
          print("Could not parse listing create response into listing")
          return
        }
        let listing = Item()
        listing.setFromJson(listingData)
        
        actualSelf.item = listing
        actualSelf.updateActionItemStates()
      }
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == Constants.EditListingSegueIdentifier {
      let vc = segue.destinationViewController as! SellDetailsPart1ViewController
      vc.item = item
      vc.categories = categories
      vc.conditions = conditions
    }
  }
  
  override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
    if identifier == Constants.EditListingSegueIdentifier {
      return categories.count > 0 && conditions.count > 0
    }
    
    return true
  }
}

extension SellerListingDetailsViewController: UITableViewDataSource, UITableViewDelegate {
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 4
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.row == 0 {
      let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TitleCellIdentifier) as! ListingTitleTableViewCell
      
      cell.configureFromItem(item)
      return cell
    } else if indexPath.row == 1 {
      let cell = tableView.dequeueReusableCellWithIdentifier(Constants.UserCellIdentifier) as! ListingOwnerTableViewCell
      
      cell.configureWithUser(User.currentUser ?? User())
      
      return cell
    } else if indexPath.row == 2 {
      let cell = tableView.dequeueReusableCellWithIdentifier(Constants.DescriptionCellIdentifier) as! ListingDescriptionTableViewCell
      
      cell.configureWithItem(item)
      
      return cell
    }
    
    let cell = tableView.dequeueReusableCellWithIdentifier(Constants.ConditionCellIdentifier) as! ListingConditionTableViewCell
    
    cell.configureWithItem(item)
    
    return cell
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if indexPath.row == 0 || indexPath.row == 3 {
      return 47
    } else if indexPath.row == 1 {
      return 63
    }
    
    return 82
  }
}

extension SellerListingDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView == imageCollectionView {
      return item.imageURLArray().count
    } else {
      return userFriends.count
    }
  }
  
  func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    if scrollView != imageCollectionView {
      return
    }
    
    let pageWidth = view.frame.size.width
    
    let currentOffset = scrollView.contentOffset.x;
    let targetOffset = targetContentOffset.memory.x;
    var newTargetOffset = CGFloat(0);
    
    if targetOffset > currentOffset {
      newTargetOffset = CGFloat(ceilf(Float(currentOffset / pageWidth)) * Float(pageWidth))
    }
    else {
      newTargetOffset = CGFloat(floorf(Float(currentOffset / pageWidth)) * Float(pageWidth))
    }
    
    if newTargetOffset < 0 {
      newTargetOffset = 0;
    }
    else if newTargetOffset > scrollView.contentSize.width {
      newTargetOffset = scrollView.contentSize.width
    }
    
    targetContentOffset.memory.x = currentOffset;
    scrollView.setContentOffset(CGPointMake(newTargetOffset, 0), animated: true)
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.ImageCollectionViewCellIdentifier, forIndexPath: indexPath) as! ListingImageCollectionViewCell
    let image = item.imageURLArray()[indexPath.row];
    
    cell.configureFor(image, numPhoto: indexPath.row + 1, totalPhotos: item.imageURLArray().count, isAmazon: image.containsString("amazonImage-"))
    
    return cell
    
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    if collectionView == imageCollectionView {
      return CGSizeMake(view.frame.size.width, collectionView.frame.size.height)
    } else {
      return CGSizeMake(61, 80)
    }
  }
}

extension SellerListingDetailsViewController: MKMapViewDelegate {
  func addRadiusCircle(location: CLLocation){
    let circle = MKCircle(centerCoordinate: location.coordinate, radius: 10000 as CLLocationDistance)
    mapView?.addOverlay(circle)
    
    var region = MKCoordinateRegion()
    region.center = location.coordinate
    
    var span = MKCoordinateSpan()
    span.latitudeDelta  = 1; // Change these values to change the zoom
    span.longitudeDelta = 1;
    region.span = span;
    
    mapView?.setRegion(region, animated: true)
  }
  
  func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
    let circle = MKCircleRenderer(overlay: overlay)
    circle.strokeColor = UIColor.redColor()
    circle.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.1)
    circle.lineWidth = 1
    return circle
  }
}