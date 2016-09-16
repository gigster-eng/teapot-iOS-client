//
//  SellDetailsPart1.swift
//  Teapot
//
//  Created by Matthew Baker on 3/18/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import Foundation
import UIKit

class SellDetailsPart1ViewController: UIViewController {
  var item: Item = Item()
  var categories: [String] = []
  var conditions: [String] = []
  
  @IBOutlet weak var tableView: UITableView?
  
  class Constants {
    static let InputCellIdentifier = "InputCell"
    static let SellDetailsPart2SegueIdentifier = "SellDetailsPart2Segue"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView?.tableFooterView = UIView()
    tableView?.tableFooterView?.backgroundColor = UIColor.whiteColor()
  }
  
  override func viewWillAppear(animated: Bool) {
    titleValue = item.title
    categoryValue = item.category
  }
  
  @IBAction func nextTapped(sender: AnyObject) {
    let title = titleValue
    let category = categoryValue
    
    if title == nil || title == "" {
      return
    }
    if category == nil || category == "" {
      return
    }
    
    item.title = title
    item.category = category
    
    performSegueWithIdentifier(Constants.SellDetailsPart2SegueIdentifier, sender: nil)
  }
  
  override var hidesBottomBarWhenPushed: Bool {
    get {
      return true
    }
    set {
      
    }
  }
  
  var titleValue: String? {
    get {
      return textEntryCellAtIndex(0)?.inputValue
    }
    set {
      textEntryCellAtIndex(0)?.inputValue = newValue
    }
  }
  
  func textEntryCellAtIndex(index: Int) -> TextEntryTableViewCell? {
    return tableView?.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as? TextEntryTableViewCell
  }
  
  var categoryValue: String? {
    get {
      return textEntryCellAtIndex(1)?.inputValue
    }
    set {
      textEntryCellAtIndex(1)?.inputValue = newValue
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == Constants.SellDetailsPart2SegueIdentifier {
      let vc = segue.destinationViewController as! SellDetailsPart2ViewController
      vc.item = item
      vc.conditions = conditions
    }
  }
}

extension SellDetailsPart1ViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(Constants.InputCellIdentifier) as! TextEntryTableViewCell
    
    let keyboardType = UIKeyboardType.ASCIICapable
    var pickListItems: [String] = []
    var placeholder = "Title *"
    if indexPath.row == 1 {
      placeholder = "Category *"
      pickListItems = categories
    }
    
    cell.setup(placeholder, keyboardType: keyboardType, delegate: self, leadingLabelText: nil, pickListItems: pickListItems)
    return cell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 0
  }
  
  func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0
  }
}

extension SellDetailsPart1ViewController: UITextFieldDelegate {
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    
    //find the UITableViewcell superview
    var cell: UIView? = textField;
    while cell != nil && cell?.isKindOfClass(UITableViewCell) == false {
      cell = cell?.superview
    }
    
    //use the UITableViewcell superview to get the NSIndexPath
    if let indexPath = tableView?.indexPathForRowAtPoint(cell?.center ?? CGPointMake(0,0)) {
      let nextIndex = indexPath.row + 1
      if nextIndex > 1 {
        nextTapped(self)
        return true
      }
      
      let cell = tableView?.cellForRowAtIndexPath(NSIndexPath(forRow: nextIndex, inSection: 0)) as! TextEntryTableViewCell
      cell.textValue?.becomeFirstResponder()
    }
    
    return true
  }
}