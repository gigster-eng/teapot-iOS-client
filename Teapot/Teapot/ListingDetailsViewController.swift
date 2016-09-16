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
import MZFormSheetPresentationController
import HCSStarRatingView
import DGRunkeeperSwitch
import Branch

class ListingDetailsViewController: UIViewController, DGRunkeeperSwitchProtocol {
  var item: Item = Item()
  var userFriends: [User] = []
  var amazonItem: ProductSearchResult? = nil
  var userOrAmazonSwitch: DGRunkeeperSwitch!
  var hasInitialized = false
  weak public var deepLinkingCompletionDelegate: BranchDeepLinkingControllerCompletionDelegate!
  
  @IBOutlet weak var tableView: UITableView?
  @IBOutlet weak var imageCollectionView: UICollectionView?
  @IBOutlet weak var connectionsCollectionView: UICollectionView?
  @IBOutlet weak var friendsWithLabel: UILabel?
  @IBOutlet weak var scrollView: UIScrollView?
  @IBOutlet weak var mapView: MKMapView?
  @IBOutlet weak var amazonStarRating: HCSStarRatingView?
  @IBOutlet weak var buyFromAmazonView: UIView?
  @IBOutlet weak var amazonTagline: UILabel?
  @IBOutlet weak var reviewsButton: UIButton?
  @IBOutlet weak var amazonPrice: UILabel?
  
  class Constants {
    static let TitleCellIdentifier = "Cell1"
    static let UserCellIdentifier = "Cell2"
    static let DescriptionCellIdentifier = "Cell3"
    static let ConditionCellIdentifier = "Cell4"
    static let ImageCollectionViewCellIdentifier = "ImageCollectionViewCell"
    static let ConnectionCellIdentifier = "ConnectionCell"
    static let OfferToBuyViewControllerIdentifier = "OfferToBuyViewController"
    static let ShowMessageSeugeIdentifier = "ShowMessageSeuge"
    static let SellerProfileSegue = "SellerProfileSegue"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    amazonStarRating?.tintColor = UIColor.kitYellow()
    navigationItem.title = item.title
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    scrollView?.contentSize = CGSizeMake(view.frame.size.width,833)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationItem.rightBarButtonItems?.removeAll()
    if hasInitialized == false && item.listingId != nil {
      hasInitialized = true
      
      displayListing()
    }
    else if deepLinkingCompletionDelegate != nil {
      let rightButton = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: #selector(ListingDetailsViewController.closeTapped))
      rightButton.tintColor = UIColor.whiteColor()
      navigationItem.setRightBarButtonItem(rightButton, animated: false)
    }
  }
  
  func displayListing() {
    if item.location != nil {
      let location = CLLocation(latitude: item.location.latitude as CLLocationDegrees, longitude: item.location.longitude as CLLocationDegrees)
      
      addRadiusCircle(location)
    }
    tableView?.reloadData()
    imageCollectionView?.reloadData()
    
    userFriends = item.user.trustGraph?.commonFriends ?? []
    friendsWithLabel?.text = String(format: "Friends with %@ (%ld)", item.user.first_name, userFriends.count)
    connectionsCollectionView?.reloadData()
    
    if userOrAmazonSwitch == nil {
      userOrAmazonSwitch = getDGRunkeeperSwitch(String(format: "FROM %@", item.user.first_name.uppercaseString), rightTitle: "NEW FROM AMAZON")
      userOrAmazonSwitch.addTarget(self, action: #selector(ListingDetailsViewController.segmentSwitchChanged), forControlEvents: .ValueChanged)
      navigationItem.titleView = userOrAmazonSwitch
    }
    
    if item.amazonAsin == nil || item.amazonAsin == "" {
      userOrAmazonSwitch?.hidden = true
    } else {
      userOrAmazonSwitch?.hidden = false
      
      //required params are app id and query
      let params:[String:AnyObject] = [
        "app": AppConfiguration.appId,
        "query": item.amazonAsin!
      ]
      MBProgressHUD.showHUDAddedTo(self.buyFromAmazonView, animated: true)
      Connection(configuration: nil).productSearchCall(params, completionBlock: { (response, error) -> Void in
        if error != nil {
          print(error.localizedDescription)
          return
        }
        
        //convert response to array
        guard let products = response as? [String:AnyObject] else {
          print("Could not parse product search response into products")
          return
        }
        guard let itemListings = products["products"] as? [[String:AnyObject]] else {
          print("Could not parse product search response into results array")
          return
        }
        var searchResults = [ProductSearchResult]()
        for itemJson in itemListings {
          let item = ProductSearchResult()
          item.setFromJson(itemJson)
          searchResults.append(item)
        }
        
        dispatch_async(dispatch_get_main_queue(), {[weak self] () -> Void in
          if let actualSelf = self {
            if searchResults.count == 0 {
              return
            }
            
            let item = searchResults.first!
            actualSelf.amazonItem = item
            actualSelf.amazonStarRating?.value = CGFloat(item.averageRating ?? 0)
            
            let salesRank = item.salesRank ?? 0
            let productgroup = item.productGroup
            
            if productgroup != nil {
              actualSelf.amazonTagline?.text = String(format: "Number %ld in %@ on Amazon", salesRank, productgroup!)
              actualSelf.amazonTagline?.hidden = false
            } else {
              actualSelf.amazonTagline?.hidden = true
            }
            
            if let price = item.price {
              actualSelf.amazonPrice?.text = String(format: "$%.0f", price)
            } else {
              actualSelf.amazonPrice?.hidden = true
            }
            
            if let attributed = actualSelf.reviewsButton?.attributedTitleForState(.Normal)!.mutableCopy() as? NSMutableAttributedString {
              let numRatings = item.numRatings ?? 0
              attributed.mutableString.setString(String(format: "(%ld) See all reviews", numRatings))
              actualSelf.reviewsButton?.setAttributedTitle(attributed, forState: .Normal)
            }
            
          }
          MBProgressHUD.hideHUDForView(self?.buyFromAmazonView, animated: true)
          })
      })
      
    }
  }
  
  @IBAction func segmentSwitchChanged(sender: AnyObject) {
    scrollView?.setContentOffset(CGPointMake(0, -(self.scrollView?.contentInset.top ?? 0)), animated: false)
    
    if userOrAmazonSwitch?.selectedIndex == 1 {
      // Amazon
      tableView?.hidden = true
      connectionsCollectionView?.hidden = true
      friendsWithLabel?.hidden = true
      mapView?.hidden = true
      scrollView?.scrollEnabled = false
      buyFromAmazonView?.hidden = false
    } else {
      // From User
      tableView?.hidden = false
      connectionsCollectionView?.hidden = false
      friendsWithLabel?.hidden = false
      mapView?.hidden = false
      scrollView?.scrollEnabled = true
      buyFromAmazonView?.hidden = true
    }
  }
  
  @IBAction func buyFromAmazonTapped(sender: AnyObject) {
    if let url = amazonItem?.amazonURL {
      if UIApplication.sharedApplication().canOpenURL(url) {
        UIApplication.sharedApplication().openURL(url)
      }
    }
  }
  
  @IBAction func buyTapped(sender: AnyObject) {
    let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
    let viewController = storyboard.instantiateViewControllerWithIdentifier(Constants.OfferToBuyViewControllerIdentifier) as! OfferToBuyViewController
    viewController.item = item
    
    let formSheetController = MZFormSheetPresentationViewController(contentViewController: viewController)
    formSheetController.presentationController?.contentViewSize = viewController.preferredSize
    formSheetController.presentationController?.shouldCenterVertically = true
    formSheetController.contentViewCornerRadius = 5.0
    formSheetController.allowDismissByPanningPresentedView = true
    
    presentViewController(formSheetController, animated: true, completion: nil)
  }
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == Constants.ShowMessageSeugeIdentifier {
      let vc = segue.destinationViewController as! MessagesViewController
      vc.listing = item
      vc.title = item.title
    } else if segue.identifier == Constants.SellerProfileSegue {
      let vc = segue.destinationViewController as! FriendDetailViewController
      vc.user = item.user
    }
  }
  
}

extension ListingDetailsViewController: UITableViewDataSource, UITableViewDelegate {
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if item.listingId == nil {
      return 0
    }
    
    return 4
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.row == 0 {
      let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TitleCellIdentifier) as! ListingTitleTableViewCell
      
      cell.configureFromItem(item)
      return cell
    } else if indexPath.row == 1 {
      let cell = tableView.dequeueReusableCellWithIdentifier(Constants.UserCellIdentifier) as! ListingOwnerTableViewCell
      
      cell.configureWithUser(item.user)
      cell.delegate = self
      
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

extension ListingDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
    if collectionView == imageCollectionView {
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.ImageCollectionViewCellIdentifier, forIndexPath: indexPath) as! ListingImageCollectionViewCell
      let image = item.imageURLArray()[indexPath.row];
      
      cell.configureFor(image, numPhoto: indexPath.row + 1, totalPhotos: item.imageURLArray().count, isAmazon: image.containsString("amazonImage-"))
      
      return cell
    } else {
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.ConnectionCellIdentifier, forIndexPath: indexPath) as! ListingFriendCollectionViewCell
      
      let user = userFriends[indexPath.row]
      cell.configurWithUser(user)
      
      return cell
    }
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    if collectionView == imageCollectionView {
      return CGSizeMake(view.frame.size.width, collectionView.frame.size.height)
    } else {
      return CGSizeMake(61, 80)
    }
  }
}

extension ListingDetailsViewController: MKMapViewDelegate {
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

extension ListingDetailsViewController: BranchDeepLinkingController {
  @IBAction func closeTapped(sender: AnyObject) {
    item = Item()
    hasInitialized = false
    
    self.deepLinkingCompletionDelegate!.deepLinkingControllerCompleted()
  }
  
  func configureControlWithData(data: [NSObject : AnyObject]!) {
    let listingId = data["listingId"] as? String
    if listingId == nil {
      deepLinkingCompletionDelegate!.deepLinkingControllerCompleted()
    }
    
    MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    Connection(configuration: nil).getListingCall(listingId) {[weak self] (response, error) in
      self?.hasInitialized = true
      if error != nil {
        print(error.localizedDescription)
        
        self?.deepLinkingCompletionDelegate!.deepLinkingControllerCompleted()
        MBProgressHUD.hideHUDForView(self?.view, animated: true)
        return
      }
      
      guard let listing = response as? [String:AnyObject] else {
        print("Could not parse listings call into dictionary")
        return
      }
      
      self?.item = Item(json: listing)
      dispatch_async(dispatch_get_main_queue(), {
        self?.displayListing()
        MBProgressHUD.hideHUDForView(self?.view, animated: true)
      })
    }
  }
}

extension ListingDetailsViewController: ListingOwnerTableViewCellDelegate {
  func listingOwnerTableViewCellTapped(user: User) {
    performSegueWithIdentifier(Constants.SellerProfileSegue, sender: item)
  }
}