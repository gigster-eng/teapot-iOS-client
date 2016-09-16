//
//  AutocompleteSearchBar.swift
//  Teapot
//
//  Created by Matthew Baker on 3/17/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import Foundation
import UIKit

func debounce( delay:NSTimeInterval, queue:dispatch_queue_t, action: (()->()) ) -> ()->() {
  var lastFireTime:dispatch_time_t = 0
  let dispatchDelay = Int64(delay * Double(NSEC_PER_SEC))
  
  return {
    lastFireTime = dispatch_time(DISPATCH_TIME_NOW,0)
    dispatch_after(
      dispatch_time(
        DISPATCH_TIME_NOW,
        dispatchDelay
      ),
      queue) {
        let now = dispatch_time(DISPATCH_TIME_NOW,0)
        let when = dispatch_time(lastFireTime, dispatchDelay)
        if now >= when {
          action()
        }
    }
  }
}

@objc protocol AutocompleteSearchBarDelegate {
    func searchTextSelected(searchBar: AutocompleteSearchBar, term: String)
    optional func searchTextBeganEditing()
    optional func searchTextEndedEditing()
    optional func searchTextCancelTapped()
}

@IBDesignable
class AutocompleteSearchBar: UIView {
  // Our custom view from the XIB file
  var view: UIView?
  var searchView: UIView?
  private var debouncedSearch: ()->() = {return}
  private var resultsView: UITableView? = nil
  var delegate: AutocompleteSearchBarDelegate? = nil
  private var autocompleteResults: [String] = []
  var source = "seller"
  
  class Constants {
    static let AutocompleteResultCellIdentifier = "AutocompleteResult"
    static let AutocompleteSearchBarNib = "AutocompleteSearchBar"
    static let AutocompleteResultNib = "AutocompleteResult"
    static let MinimumSearchCharacters = 3
    static let SearchDebounceInterval = 0.5 //seconds
    static let CellHeight = CGFloat(30.0)
  }
  
  override init(frame: CGRect) {
    // 1. setup any properties here
    
    // 2. call super.init(frame:)
    super.init(frame: frame)
    
    // 3. Setup view from .xib file
    xibSetup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    // 1. setup any properties here
    
    // 2. call super.init(coder:)
    super.init(coder: aDecoder)
    
    // 3. Setup view from .xib file
    xibSetup()
  }
  
  func xibSetup() {
    view = loadViewFromNib()
    
    if let textEntry = textField() {
      textEntry.delegate = self
    }
    
    if let container = borderView() {
      let tap = UITapGestureRecognizer(target: self, action: "viewTapped")
      tap.enabled = true
      container.addGestureRecognizer(tap)
    }
    
    let searchDebounceInterval: NSTimeInterval = NSTimeInterval(Constants.SearchDebounceInterval)
    let q = dispatch_get_global_queue(0, 0)
    debouncedSearch = debounce(searchDebounceInterval, queue: q, action: performSearch)
    
    // use bounds not frame or it'll be offset
    view?.frame = bounds
    
    // Make the view stretch with containing view
    view?.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
    // Adding custom subview on top of our view (over any custom drawing > see note below)
    addSubview(view!)
  }
  
  func loadViewFromNib() -> UIView {
    let nib = UINib(nibName: Constants.AutocompleteSearchBarNib, bundle: nil)
    let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
    
    return view
  }
  
  func borderView() -> UIView? {
    return view?.viewWithTag(2)
  }
  
  func textField() -> UITextField? {
    return view?.viewWithTag(1) as? UITextField
  }
  
  func viewTapped() {
    if let textEntry = textField() {
      textEntry.becomeFirstResponder()
    }
  }
  
  func setSearchText(text: String) {
    textField()?.text = text
  }
  
  func removeSearchResults() {
    dispatch_async(dispatch_get_main_queue(), {[weak self] () -> Void in
      if let actualSelf = self {
        actualSelf.resultsView?.removeFromSuperview()
        actualSelf.resultsView = nil
        actualSelf.autocompleteResults = []
      }
      })
  }
  
  override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
  }
  
  func performSearch() {
    let searchTerm = textField()?.text
    
    if searchTerm == nil {
      return
    }
    
    let actualSearch: String = searchTerm!
    
    if actualSearch.characters.count == 0 {
      removeSearchResults()
    }
    
    if searchTerm?.characters.count < Constants.MinimumSearchCharacters {
      return
    }
    
    if resultsView != nil {
      removeSearchResults()
    }
    
    // Temporary search results
    autocompleteResults = []
    //required params are app id and query
    let params:[String:AnyObject] = [
      "app": AppConfiguration.appId,
      "query": searchTerm!,
      "source": source
    ]
    
    Connection(configuration: nil).suggestionsCall(params) {[weak self] (response, error) -> Void in
      if let actualSelf = self {
        if error != nil {
          print("Autocomplete error: " +  error.localizedDescription)
          return
        }
        
        //convert response to array
        guard let suggestions = response as? [String:AnyObject] else {
          print("Could not parse suggestions response into suggestions")
          return
        }
        guard let results = suggestions["suggestions"] as? [String] else {
          print("Could not parse suggestions response into list of strings")
          return
        }
        
        actualSelf.autocompleteResults = results
        if results.count == 0 {
          return
        }

        //if the vies is already there, don't add it
        if actualSelf.resultsView != nil {
            actualSelf.resultsView?.reloadData()
            return
        }
        
        if let container = actualSelf.borderView() {
          let frame = container.frame
          let size = frame.size
          
          let y = frame.origin.y + size.height
          let x = frame.origin.x
          let absoluteOrigin = actualSelf.convertPoint(CGPointMake(x, y), toView: actualSelf.searchView!)
          
          let width = size.width
          let height = CGFloat(200) // CGFloat(results.count * 30)
          
          let resultsFrame = CGRectMake(absoluteOrigin.x, absoluteOrigin.y, width, height)
          let searchResultsView = TableView(frame: resultsFrame)
          searchResultsView.dataSource = self
          searchResultsView.delegate = self
          searchResultsView.separatorStyle = .None
          searchResultsView.backgroundColor = UIColor.whiteColor()
          searchResultsView.autoresizingMask = [UIViewAutoresizing.FlexibleBottomMargin]
          searchResultsView.layer.borderWidth = container.layer.borderWidth
          searchResultsView.layer.borderColor = container.layer.borderColor
          searchResultsView.layer.cornerRadius = container.layer.cornerRadius
          searchResultsView.scrollEnabled = true
          searchResultsView.estimatedRowHeight = Constants.CellHeight
          searchResultsView.rowHeight = UITableViewAutomaticDimension
          
          let nib = UINib(nibName: Constants.AutocompleteResultNib, bundle: nil)
          searchResultsView.registerNib(nib, forCellReuseIdentifier: Constants.AutocompleteResultCellIdentifier)
          actualSelf.resultsView = searchResultsView
          
          dispatch_async(dispatch_get_main_queue(), {[weak self] () -> Void in
            if let actualSelf = self {
              actualSelf.searchView?.addSubview(searchResultsView)
              searchResultsView.reloadData()
            }
            })
        }
      }
    }
  }
}

extension AutocompleteSearchBar: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        delegate?.searchTextBeganEditing?()
    }
    func textFieldDidEndEditing(textField: UITextField) {
        delegate?.searchTextEndedEditing?()
    }
    
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    debouncedSearch()
    
    return true
  }
  
  func textFieldShouldClear(textField: UITextField) -> Bool {
    dispatch_async(dispatch_get_main_queue(), {[weak self] () -> Void in
        if let actualSelf = self {
            actualSelf.removeSearchResults()
        }
    })

    //BrowseViewController needs to hide the keyboard on clear button press.  If you return True then it autofocuses on the text field again.  That breaks the keyboard hiding behavior.
    if delegate?.searchTextCancelTapped?() != nil {
        textField.text = ""
        return false
    }

    return true
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    
    if textField.text?.characters.count < Constants.MinimumSearchCharacters {
      return false
    }
    
    dispatch_async(dispatch_get_main_queue(), {[weak self] () -> Void in
      if let actualSelf = self {
        actualSelf.removeSearchResults()
        actualSelf.delegate?.searchTextSelected(actualSelf, term: textField.text ?? "")
      }
      })
    
    return true
  }
}

extension AutocompleteSearchBar: UITableViewDataSource, UITableViewDelegate {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return autocompleteResults.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.row >= autocompleteResults.count  {
      return UITableViewCell()
    }
    
    let cell = tableView.dequeueReusableCellWithIdentifier(Constants.AutocompleteResultCellIdentifier) as! AutocompleteResult
    let result = autocompleteResults[indexPath.row]
    cell.configure(result)
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.row >= autocompleteResults.count {
      return
    }
    
    let result = autocompleteResults[indexPath.row]
    textField()?.text = result
    
    dispatch_async(dispatch_get_main_queue(), {[weak self] () -> Void in
      if let actualSelf = self {
        actualSelf.removeSearchResults()
        actualSelf.delegate?.searchTextSelected(actualSelf, term: result)
      }
      })
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return Constants.CellHeight
  }
  
  func scrollViewWillBeginDragging(scrollView: UIScrollView) {
    textField()?.resignFirstResponder()
  }
}