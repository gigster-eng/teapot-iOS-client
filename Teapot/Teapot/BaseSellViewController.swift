//
//  BaseSellViewController.swift
//  Teapot
//
//  Created by Matthew Baker on 3/20/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit
import MBProgressHUD

class BaseSellViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView?
  private var currentUser: User = User()
  
  private var activeListings: [Item] = []
  private var soldListings: [Item] = []
  private var takenDownListings: [Item] = []
  
  class Constants {
    static let CreateListingSeugeIdentifier = "CreateListingSegue"
    static let ListingCellIdentifier = "ListingCell"
    static let SellSegueIdentifier = "SellSegue"
    static let SellTableSectionHeaderNib = "SellTableSectionHeader"
    static let SellerListingDetailsSegueIdentifier = "SellerListingDetailsSegue"
    static let SellerListingDetailsImmediateSegueIdentifier = "SellerListingDetailsImmediateSegue"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    tableView?.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    if User.currentUser?.listings.count == 0 {
      tableView?.hidden = true
    } else {
      tableView?.hidden = false
      tableView?.reloadData()
      
      let params: [String: AnyObject] = [
        "app": AppConfiguration.appId,
        "person_id": ModelManager.sharedManager.getAppID(),
        "source_person_id": ModelManager.sharedManager.getAppID()
      ]
      MBProgressHUD.showHUDAddedTo(self.view, animated: true)
      Connection(configuration: nil).userProfileCall(params) {[weak self] (response, error) -> Void in
        MBProgressHUD.hideHUDForView(self?.view, animated: true)
        if let actualSelf = self {
          if error == nil {
            guard let response = response as? [String:AnyObject] else {return}
            ModelManager.sharedManager.updateUser(response)
            actualSelf.currentUser = User()
            actualSelf.currentUser.setFromJson(response)
            
            actualSelf.activeListings = []
            actualSelf.soldListings = []
            actualSelf.takenDownListings = []
            
            for listing in actualSelf.currentUser.listings {
              if listing.takenDownAt != nil {
                actualSelf.takenDownListings.append(listing)
              } else if listing.soldAt != nil {
                actualSelf.soldListings.append(listing)
              } else {
                actualSelf.activeListings.append(listing)
              }
            }
            
            actualSelf.tableView?.reloadData()
          } else {
            print("error getting user profile: " + error.localizedDescription)
          }
        }
      }
    }
  }
  
  @IBAction func postAnItemTapped(sender: AnyObject) {
    performSegueWithIdentifier(Constants.SellSegueIdentifier, sender: nil)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    if tableView?.hidden == true {
      performSegueWithIdentifier(Constants.CreateListingSeugeIdentifier, sender: nil)
    }
  }
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == Constants.SellerListingDetailsSegueIdentifier || segue.identifier == Constants.SellerListingDetailsImmediateSegueIdentifier {
      let vc = segue.destinationViewController as! SellerListingDetailsViewController
      vc.item = sender as! Item
    }
  }
}

extension BaseSellViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(Constants.ListingCellIdentifier) as! ListingTableViewCell
    
    if indexPath.section == 0 {
      if activeListings.count > indexPath.row {
        let item = activeListings[indexPath.row]
        cell.setFromItem(item)
      }
    } else if indexPath.section == 1 {
      if soldListings.count > indexPath.row {
        let item = soldListings[indexPath.row]
        cell.setFromItem(item)
      }
    } else if indexPath.section == 2 {
      if takenDownListings.count > indexPath.row {
        let item = takenDownListings[indexPath.row]
        cell.setFromItem(item)
      }
    }
    
    return cell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return activeListings.count
    } else if section == 1 {
      return soldListings.count
    }
    
    return takenDownListings.count
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 3
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let nib = UINib(nibName: Constants.SellTableSectionHeaderNib, bundle: nil)
    let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
    
    let label = view.viewWithTag(1) as! UILabel
    var title = "Your items for sale"
    if section == 1 {
      title = "Sold items"
    } else if section == 2 {
      title = "Removed items"
    }
    
    label.text = title
    
    return view
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 55
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 75
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    var array = activeListings
    if indexPath.section == 1 {
      array = soldListings
    }
    if indexPath.section == 2 {
      array = takenDownListings
    }
    
    performSegueWithIdentifier(Constants.SellerListingDetailsSegueIdentifier, sender: array[indexPath.row])
  }
}