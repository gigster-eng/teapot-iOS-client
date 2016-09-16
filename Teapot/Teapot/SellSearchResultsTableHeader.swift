//
//  SellSearchResultsTableHeader.swift
//  Teapot
//
//  Created by Matthew Baker on 3/17/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit

@IBDesignable
class SellSearchResultsTableHeader: UIView {
  // Our custom view from the XIB file
  var view: UIView!
  
  class Constants {
    static let SellSearchResultsTableHeaderNib = "SellSearchResultsTableHeader"
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
    
    // use bounds not frame or it'll be offset
    view.frame = bounds
    
    // Make the view stretch with containing view
    view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
    // Adding custom subview on top of our view (over any custom drawing > see note below)
    addSubview(view)
  }
  
  func loadViewFromNib() -> UIView {
    let bundle = NSBundle(forClass: self.dynamicType)
    let nib = UINib(nibName: Constants.SellSearchResultsTableHeaderNib, bundle: bundle)
    let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
    
    return view
  }
  
  func searchBar() -> AutocompleteSearchBar? {
    return view?.viewWithTag(1) as? AutocompleteSearchBar
  }
  
  override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
  }
}
