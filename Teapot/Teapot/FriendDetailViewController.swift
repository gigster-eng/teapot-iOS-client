//
//  FriendDetailViewController.swift
//  Teapot
//
//  Created by Matthew Baker on 5/30/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit

class FriendDetailViewController: UICollectionViewController, NetworkingProtocol, PinterestLayoutDelegate, UICollectionViewDelegateFlowLayout {
  
  struct Constant {
    static let ItemCell = "ItemCell"
    static let ListingDetailsSegueIdentifier = "ListingDetailsSegue"
    
    static let MaxLabelHeight: CGFloat = 47.0
  }
  
  var items: [Item] = []
  var user = User()
  private var sectionHeader: FriendHeaderCollectionReusableView? = nil
  
  @IBOutlet weak var layout: PinterestLayout?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = user.first_name
    
    var height: CGFloat = 330.0
    if user.trustGraph?.distance < 2 || user.trustGraph?.distance == 6 {
      height = height - 170.0
    }
    
    layout?.headerReferenceSize = CGSizeMake(300, height)
    collectionView!.backgroundColor = UIColor.kitBackground()
    collectionView!.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
    layout?.itemInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    collectionView!.registerNib(UINib(nibName: Constant.ItemCell, bundle: nil), forCellWithReuseIdentifier: Constant.ItemCell)
    layout?.delegate = self
    
    serverCall()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidLayoutSubviews() {
  }
  
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items.count ?? 0
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constant.ItemCell, forIndexPath: indexPath) as! ItemCell
    let item = items[indexPath.row]
    item.user = user
    cell.item = item
    cell.delegate = self
    return cell
  }
  
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if indexPath.row >= items.count {
      return
    }
    
    performSegueWithIdentifier(Constant.ListingDetailsSegueIdentifier, sender: items[indexPath.row])
  }
  
  override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    var reusableView = UICollectionReusableView()
    
    if (kind == UICollectionElementKindSectionHeader) {
      reusableView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath)
      if let header = reusableView as? FriendHeaderCollectionReusableView {
        header.configureWithUser(user)
        self.sectionHeader = header
      }
    }
    
    return reusableView;
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    var height: CGFloat = 330
    if user.trustGraph?.distance < 2 || user.trustGraph?.distance == 6 {
      height = height - 170
    }
    
    return CGSizeMake(collectionView.frame.size.width, height)
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    return CGSizeZero
  }
  
  func collectionView(collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {
    let item = items[indexPath.item]
    let font = UIFont(name: "Lato", size: 13)!
    let commentHeight = min(Constant.MaxLabelHeight, item.heightForTitle(font, width: width - 30))
    let height = commentHeight + 229
    
    return height
  }
  
  func serverCall() {
    let params: [String: AnyObject] = [
      "app": AppConfiguration.appId,
      "person_id": user.id,
      "source_person_id": ModelManager.sharedManager.getAppID()
    ]
    
    showLoader()
    Connection(configuration: nil).userProfileCall(params) {[weak self] (response, error) -> Void in
      self?.hideLoader()
      if let actualSelf = self {
        if error == nil {
          print(response)
          guard let response = response as? [String:AnyObject] else {return}
          actualSelf.user = User()
          actualSelf.user.setFromJson(response)
          
          actualSelf.items = []
          for item in actualSelf.user.listings {
            actualSelf.items.append(item)
          }
          
          actualSelf.sectionHeader?.configureWithUser(actualSelf.user)
          actualSelf.layout?.emptyLayoutCache()
          actualSelf.collectionView?.reloadData()
          actualSelf.sectionHeader?.needsUpdateConstraints()
          actualSelf.sectionHeader?.layoutIfNeeded()
        } else {
          print("error getting user profile: " + error.localizedDescription)
        }
      }
    }
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
    if segue.identifier == "ListingDetailsSegue" {
      let vc = segue.destinationViewController as! ListingDetailsViewController
      vc.item = sender as! Item
    }
  }
}

extension FriendDetailViewController: ItemListingProtocol {
  func didTapCategory(category: String){
    
  }
  
  func didTapLocation(location: Location){
    
  }
}