//
//  SellNewSearchViewController.swift
//  Teapot
//
//  Created by Matthew Baker on 3/17/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import Foundation
import UIKit

class SellNewSearchViewController: UIViewController {
  @IBOutlet weak var customSearchBar: AutocompleteSearchBar?
  
  private var selectedSearchTerm: String? = nil
  
  class Constants {
    static let SearchPerformedSegueIdentifier = "SearchPerformedSegue"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    customSearchBar?.delegate = self
    customSearchBar?.searchView = self.view
  }
  
  override var hidesBottomBarWhenPushed: Bool {
    get {
      return false
    }
    set {
      
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    let current = User.currentUser;
    if current?.listings.count == 0 {
      navigationItem.hidesBackButton = true
    }
    customSearchBar?.removeSearchResults()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == Constants.SearchPerformedSegueIdentifier {
      let vc = segue.destinationViewController as! SellSearchResultsViewController
      vc.searchTerm = selectedSearchTerm
    }
  }
}

extension SellNewSearchViewController: AutocompleteSearchBarDelegate {
  func searchTextSelected(searchBar: AutocompleteSearchBar, term: String) {
    selectedSearchTerm = term
    performSegueWithIdentifier(Constants.SearchPerformedSegueIdentifier, sender: nil)
  }
}