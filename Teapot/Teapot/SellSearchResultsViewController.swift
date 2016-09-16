//
//  SellSearchResultsViewController.swift
//  Teapot
//
//  Created by Matthew Baker on 3/17/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

class SellSearchResultsViewController: UIViewController {
  var searchTerm: String? = nil
  @IBOutlet weak var tableHeader: SellSearchResultsTableHeader?
  @IBOutlet weak var tableView: TableView!
  @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint?
  @IBOutlet weak var nextButton: DesignableButton?
  
  var searchResults: [ProductSearchResult]? = nil
  var conditions: [String] = []
  var categories: [String] = []
  
  class Constants {
    static let SellSearchResultCellIdentifier = "SellSearchResultCell"
    static let SellSearchNoResultsCellIdentifier = "NoSearchResultsCell"
    static let SellDetailsPart1SegueIdentifier = "SellDetailsPart1Segue"
  }
  
  override func viewDidLoad() {
    tableHeader?.searchBar()?.delegate = self
    tableHeader?.searchBar()?.searchView = self.view
    tableHeader?.searchBar()?.setSearchText(searchTerm ?? "")
    tableView?.tableFooterView = UIView()
    tableView?.tableFooterView?.backgroundColor = UIColor.whiteColor()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    tableHeader?.searchBar()?.removeSearchResults()
    serverCall()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    adjustHeightOfTableview()
  }
  
  override var hidesBottomBarWhenPushed: Bool {
    get {
      return true
    }
    set {
      
    }
  }
  
  func serverCall(){
    if searchTerm == nil {
      return
    }
    
    //required params are app id and query
    let params:[String:AnyObject] = [
      "app": AppConfiguration.appId,
      "query": searchTerm!
    ]
    
    MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    Connection(configuration: nil).productSearchCall(params) {[weak self] response, error in
      if error == nil {
        //convert response to array
        guard let products = response as? [String:AnyObject] else {
          print("Could not parse product search response into products")
          MBProgressHUD.hideHUDForView(self?.view, animated: true)
          
          return
        }
        guard let itemListings = products["products"] as? [[String:AnyObject]] else {
          print("Could not parse product search response into results array")
          MBProgressHUD.hideHUDForView(self?.view, animated: true)
          
          return
        }
        self?.searchResults = [ProductSearchResult]()
        for itemJson in itemListings {
          let item = ProductSearchResult()
          item.setFromJson(itemJson)
          self?.searchResults!.append(item)
        }
        dispatch_async(dispatch_get_main_queue(), {[weak self] () -> Void in
          if let actualSelf = self {
            actualSelf.tableView.reloadData()
            actualSelf.adjustHeightOfTableview()
          }
        })
        
        Connection(configuration: nil).getSettings({[weak self] (response, error) in
          MBProgressHUD.hideHUDForView(self?.view, animated: true)
          if error != nil {
            print(error.localizedDescription)
            return
          }
          
          guard let settings = response as? [String:AnyObject] else {
            print("Could not parse settings response into settings")
            return
          }
          guard let selling = settings["selling"] as? [String:AnyObject] else {
            print("Could not parse selling response into settings")
            return
          }
          
          self?.conditions = (selling["conditions"] as? [String] ?? [])
          self?.categories = (selling["categories"] as? [String] ?? [])
        })
      } else {
        self?.showOKAlertView(nil, message: "Oops, something went wrong. Please give us a few minutes to fix the problem.")
      }
    }
  }

  
  @IBAction func manualEntryTapped(sender: AnyObject) {
    if shouldPerformSegueWithIdentifier(Constants.SellDetailsPart1SegueIdentifier, sender: nil) {
      performSegueWithIdentifier(Constants.SellDetailsPart1SegueIdentifier, sender: nil)
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == Constants.SellDetailsPart1SegueIdentifier {
      let item = sender as? ProductSearchResult
      let vc = segue.destinationViewController as! SellDetailsPart1ViewController
      if let item = item {
        vc.item.setFromProductResult(item)
      }
      
      vc.categories = categories
      vc.conditions = conditions
    }
  }
  
  override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
    if identifier == Constants.SellDetailsPart1SegueIdentifier {
      return categories.count > 0 && conditions.count > 0
    }
    
    return true
  }
  
  func adjustHeightOfTableview() {
    var height = tableView.contentSize.height
    let maxHeight = nextButton!.frame.origin.y - 20 - tableView.frame.origin.y
    
    if height > maxHeight {
      height = maxHeight
    }
    
    tableViewHeightConstraint?.constant = height
    view.setNeedsUpdateConstraints()
  }
}

extension SellSearchResultsViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if searchResults == nil {
      return 0
    }
    
    if searchResults!.count == 0 {
      return 1
    } else {
      return searchResults!.count
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if searchResults!.count == 0 {
      let cell = tableView.dequeueReusableCellWithIdentifier(Constants.SellSearchNoResultsCellIdentifier, forIndexPath: indexPath)
      
      return cell
    }
    
    let cell = tableView.dequeueReusableCellWithIdentifier(Constants.SellSearchResultCellIdentifier, forIndexPath: indexPath) as! SellSearchResultTableViewCell
    
    let item = searchResults![indexPath.row]
    cell.setFromProductSearchResult(item)
    
    return cell
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 75.0
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    if searchResults!.count <= indexPath.row {
      return
    }
    
    let result = searchResults![indexPath.row]
    
    performSegueWithIdentifier(Constants.SellDetailsPart1SegueIdentifier, sender: result)
  }
  
  func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 0
  }
}

extension SellSearchResultsViewController: AutocompleteSearchBarDelegate {
  func searchTextSelected(searchBar: AutocompleteSearchBar, term: String) {
    searchTerm = term
    serverCall()
  }
}