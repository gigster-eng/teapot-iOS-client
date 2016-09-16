//
//  SellDetailsPart3ViewController.swift
//  Teapot
//
//  Created by Matthew Baker on 3/18/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit
import DBCamera
import RealmSwift
import Photos

struct ImageToUpload {
  var image: UIImage
  var external: Bool
}

class SellDetailsPart3ViewController: UIViewController {
  var item: Item = Item()
  
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
  @IBOutlet weak var externalImagesCollectionView: UICollectionView?
  @IBOutlet weak var takenPhotosCollectionView: UICollectionView?
  @IBOutlet weak var nextButton: DesignableButton?
  @IBOutlet weak var externalImagesHeightConstraint: NSLayoutConstraint?
  
  private var unifiedImages: [String] = []
  private var albumImages: [UIImage] = []
  private var takenImages: [UIImage] = []
  
  class Constants {
    static let ChooseImageCellIdentifier = "ChooseImageCollectionViewCell"
    static let SellerListingVCIdentifier = "SellerListingDetailsViewController"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    externalImagesCollectionView?.allowsMultipleSelection = true
    takenPhotosCollectionView?.allowsMultipleSelection = true
    
    for link in item.imageURLArray() {
      unifiedImages.append(link)
    }
    
    let fetchOptions = PHFetchOptions()
    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    
    let maxResults = 24
    let fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions)
    var count = maxResults
    if fetchResult.count != 0 && fetchResult.count < count {
      count = fetchResult.count
    }
    
    for index in 0...count-1 {
      if let asset: PHAsset = fetchResult.objectAtIndex(index) as? PHAsset {
        let manager = PHImageManager.defaultManager()
        let imageRequestOptions = PHImageRequestOptions()
        
        manager.requestImageDataForAsset(asset, options: imageRequestOptions) {[weak self]
          (let imageData: NSData?, let dataUTI: String?,
          let orientation: UIImageOrientation,
          let info: [NSObject : AnyObject]?) -> Void in
          
          if let imageDataUnwrapped = imageData, lastImageRetrieved = UIImage(data: imageDataUnwrapped) {
            self?.albumImages.append(lastImageRetrieved)
            self?.externalImagesCollectionView?.reloadData()
          }
        }
      }
    }
    
    if (UIScreen.mainScreen().bounds.size.height < 568) {
      externalImagesHeightConstraint?.constant = 100
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override var hidesBottomBarWhenPushed: Bool {
    get {
      return true
    }
    set {
      
    }
  }
  
  @IBAction func nextTapped(sender: AnyObject) {
    let selectedExternal = externalImagesCollectionView?.indexPathsForSelectedItems() ?? []
    let selectedTaken = takenPhotosCollectionView?.indexPathsForSelectedItems() ?? []
    let totalImages = selectedExternal.count + selectedTaken.count
    
    if totalImages == 0 {
      return
    }
    
    activityIndicator?.startAnimating()
    nextButton?.setTitle("", forState: .Normal)
    nextButton?.enabled = false
    
    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
    dispatch_async(dispatch_get_global_queue(priority, 0)) {
      // do some task
      var images: [ImageToUpload] = []
      var itemImageUrls: [String] = []
      
      for item in selectedExternal {
        let cell = self.externalImagesCollectionView?.cellForItemAtIndexPath(item) as! ChooseImageCollectionViewCell
        
        // Don't upload this again if it's already attached to the listing
        if let url = cell.image?.sd_imageURL() {
          if self.item.imageURLArray().contains(url.absoluteString) {
            itemImageUrls.append(url.absoluteString)
            continue
          }
        }
        
        if let image = cell.image?.image {
          images.append(ImageToUpload(image: image, external: true))
        }
      }
      for item in selectedTaken {
        let cell = self.takenPhotosCollectionView?.cellForItemAtIndexPath(item) as! ChooseImageCollectionViewCell
        if let image = cell.image?.image {
          images.append(ImageToUpload(image: image, external: false))
        }
      }
      
      var imageUrlsToUpload: [NSURL] = []
      
      // save images to disk
      for var image in images {
        image.image = image.image.fixOrientation()!
        if let data = UIImagePNGRepresentation(image.image) {
          var prefix = ""
          if image.external == true {
            prefix = "amazonImage-"
          }
          if let url = data.writeToTempfile(prefix, fileExtension: "png") {
            imageUrlsToUpload.append(url)
          }
        }
      }
      
      // set image links for item
      self.item.imageURLs = ""
      for url in imageUrlsToUpload {
        itemImageUrls.append("https://" + AppConfiguration.ProductFilesBucket + ".s3.amazonaws.com/" + url.lastPathComponent!)
      }
      self.item.imageURLs = itemImageUrls.joinWithSeparator(",")
      
      // Upload images
      self.uploadImages(imageUrlsToUpload) {[weak self] () -> Void in
        if let actualSelf = self {
          
          dispatch_async(dispatch_get_main_queue()) {
            // update some UI
            // POST item
            let params:[String:AnyObject] = [
              "app": AppConfiguration.appId,
              "listing": actualSelf.item.getJson(),
              "creator_id": User.currentUser?.id ?? ""
            ]
            
            Connection(configuration: nil).createUpdateListing(params) {[weak self] response, error in
              if let actualSelf = self {
                actualSelf.activityIndicator?.stopAnimating()
                actualSelf.nextButton?.setTitle("Next", forState: .Normal)
                actualSelf.nextButton?.enabled = true
                
                if error != nil {
                  actualSelf.showOKAlertView("Error", message: "Oops, something went wrong. Please give us a few minutes to fix the problem.")
                  return
                }
                
                print("Edit Response \(response)")
                guard let listingData = response as? [String:AnyObject] else {
                  print("Could not parse listing create response into listing")
                  return
                }
                
                let listing = Item()
                listing.setFromJson(listingData)
                
                if actualSelf.item.listingId != nil {
                  let vc = actualSelf.navigationController!.viewControllers[1] as! SellerListingDetailsViewController
                  vc.item = listing
                  actualSelf.navigationController?.popToViewController(vc, animated: true)
                  return
                }
                
                // Get the default Realm
                let realm = try! Realm()
                
                // Persist your data easily
                try! realm.write {
                  User.currentUser?.listings.append(listing)
                }
                
                if var viewControllers = actualSelf.navigationController?.viewControllers {
                  let storyboard = UIStoryboard(name: "Main", bundle: nil)
                  let listingVc = storyboard.instantiateViewControllerWithIdentifier(Constants.SellerListingVCIdentifier) as! SellerListingDetailsViewController
                  listingVc.item = listing
                  
                  let newViewControllers: [UIViewController] = [viewControllers[0], listingVc]
                  actualSelf.navigationController?.viewControllers = newViewControllers
                  actualSelf.navigationController?.popViewControllerAnimated(true)
                  
                  return
                }
                
                actualSelf.navigationController?.popToRootViewControllerAnimated(true)
              }
            }
          }
        }
      }
    }
  }
  
  func uploadImages(urls: [NSURL], callback: ()->Void) {
    let s3Manager = AWSS3Manager()
    if urls.count == 0 {
      callback()
      return
    }
    
    s3Manager.uploadFile(urls.first!, callback:{[weak self] (err, key) -> Void in
      if let actualSelf = self {
        if err == nil {
          actualSelf.uploadImages(Array(urls.dropFirst(1)), callback: callback)
        } else {
          actualSelf.showOKAlertView("Error", message: "An error occurred while uploading one or more images")
          actualSelf.activityIndicator?.stopAnimating()
          actualSelf.nextButton?.setTitle("Next", forState: .Normal)
          actualSelf.nextButton?.enabled = true
        }
      }
    })
  }
  
  @IBAction func takePhotoTapped(sender: AnyObject) {
    let cameraController = DBCameraViewController.initWithDelegate(self)
    cameraController.useCameraSegue = false;
    
    let container = DBCameraContainerViewController(delegate: self) { (cameraView, container) in
      cameraView.photoLibraryButton.hidden = true
    }
    container.cameraViewController = cameraController
    container.setFullScreenMode();
    
    let nav = UINavigationController(rootViewController: container)
    nav.setNavigationBarHidden(true, animated: false)
    presentViewController(nav, animated: true, completion: nil)
  }
  
}

extension SellDetailsPart3ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constants.ChooseImageCellIdentifier, forIndexPath: indexPath) as! ChooseImageCollectionViewCell
    
    cell.image?.sd_cancelCurrentImageLoad()
    cell.image?.image = nil
    
    if collectionView == takenPhotosCollectionView {
      let image = takenImages[indexPath.row]
      cell.image?.image = image
    } else {
      if indexPath.row < unifiedImages.count {
        let url = NSURL(string: unifiedImages[indexPath.row])!
        cell.image?.sd_setImageWithURL(url)
      } else {
        cell.image?.image = albumImages[indexPath.row - unifiedImages.count]
      }
    }
    
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView == takenPhotosCollectionView {
      return takenImages.count
    }
    
    return unifiedImages.count + albumImages.count
  }
  
  func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    let selectedExternal = externalImagesCollectionView?.indexPathsForSelectedItems()
    let selectedTaken = takenPhotosCollectionView?.indexPathsForSelectedItems()
    let totalSelected = (selectedExternal?.count ?? 0) + (selectedTaken?.count ?? 0)
    
    if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
      if cell.selected {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        return false
      } else if totalSelected < 3 {
        collectionView.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: .CenteredHorizontally)
        return true
      }
    }
    
    return false
  }
  
  func collectionView(collectionView: UICollectionView, shouldDeselectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
    if collectionView == externalImagesCollectionView {
      if indexPath.row < unifiedImages.count {
        if item.imageURLArray().contains(unifiedImages[indexPath.row]) {
          let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
          dispatch_after(delayTime, dispatch_get_main_queue()) {
            collectionView.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: .CenteredHorizontally)
          }
        }
      }
    }
  }
}

extension SellDetailsPart3ViewController: UITextFieldDelegate {
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    
    return true
  }
}

extension SellDetailsPart3ViewController: DBCameraViewControllerDelegate {
  func camera(cameraViewController: AnyObject!, didFinishWithImage image: UIImage!, withMetadata metadata: [NSObject : AnyObject]!) {
    let shrunk = image.scaleImageToSize(2208) // height doesn't matter
    takenImages.append(shrunk)
    
    let selectedExternal = externalImagesCollectionView?.indexPathsForSelectedItems() ?? []
    let selectedTaken = takenPhotosCollectionView?.indexPathsForSelectedItems() ?? []
    let totalImages = selectedExternal.count + selectedTaken.count
    
    takenPhotosCollectionView?.performBatchUpdates({[weak self] () -> Void in
      if let takenImages = self?.takenImages {
        self?.takenPhotosCollectionView?.insertItemsAtIndexPaths([NSIndexPath(forRow: takenImages.count - 1, inSection: 0)])
      }
      }, completion: {[weak self] (done) -> Void in
        if let takenImages = self?.takenImages {
          // Only select this taken photo if the total prior to adding it is <= 2
          if totalImages <= 2 {
            self?.takenPhotosCollectionView?.selectItemAtIndexPath(NSIndexPath(forRow: takenImages.count - 1, inSection: 0), animated: true, scrollPosition: .CenteredHorizontally)
          }
        }
      })
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func dismissCamera(cameraViewController: AnyObject!) {
    dismissViewControllerAnimated(true, completion: nil)
  }
}