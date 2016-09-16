//
//  SellDetailsPart2ViewController.swift
//  Teapot
//
//  Created by Matthew Baker on 3/18/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit

class SellDetailsPart2ViewController: UIViewController {
  var item: Item = Item()
  var conditions: [String] = []
  
  @IBOutlet weak var tableView: UITableView?
  
  class Constants {
    static let InputCellIdentifier = "InputCell"
    static let SellDetailsPart3SegueIdentifier = "SellDetailsPart3Segue"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView?.tableFooterView = UIView()
    tableView?.tableFooterView?.backgroundColor = UIColor.whiteColor()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillAppear(animated: Bool) {
    descriptionValue = item.itemDescription
    priceValue = item.price == nil ? "" : String(format:"%.0f", item.price)
    conditionValue = item.condition
  }
  
  @IBAction func nextTapped(sender: AnyObject) {
    let description = descriptionValue
    let price = Double(priceValue ?? "")
    let condition = conditionValue
    
    if description == nil || description == "" {
      return
    }
    if price == nil {
      return
    }
    if condition == nil || condition == "" {
      return
    }
    
    item.itemDescription = description
    item.price = price
    item.condition = condition
    
    performSegueWithIdentifier(Constants.SellDetailsPart3SegueIdentifier, sender: nil)
  }
  
  override var hidesBottomBarWhenPushed: Bool {
    get {
      return true
    }
    set {
      
    }
  }
  
  var descriptionValue: String? {
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
  
  var priceValue: String? {
    get {
      return textEntryCellAtIndex(1)?.inputValue
    }
    set {
      textEntryCellAtIndex(1)?.inputValue = newValue
    }
  }
  
  var conditionValue: String? {
    get {
      return textEntryCellAtIndex(2)?.inputValue
    }
    set {
      textEntryCellAtIndex(2)?.inputValue = newValue
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == Constants.SellDetailsPart3SegueIdentifier {
      let vc = segue.destinationViewController as! SellDetailsPart3ViewController
      vc.item = item
    }
  }

  
}

extension SellDetailsPart2ViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(Constants.InputCellIdentifier) as! TextEntryTableViewCell
    
    var keyboardType = UIKeyboardType.ASCIICapable
    var placeholder = "Description *"
    var pickListItems: [String] = []
    var leadingLabel: String? = nil
    if indexPath.row == 1 {
      placeholder = "Price *"
      keyboardType = UIKeyboardType.NumberPad
      leadingLabel = "$"
    } else if indexPath.row == 2 {
      placeholder = "Condition *"
      pickListItems = conditions
    }
    
    cell.setup(placeholder, keyboardType: keyboardType, delegate: self, leadingLabelText: leadingLabel, pickListItems: pickListItems)
    return cell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 0
  }
  
  func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0
  }
}

extension SellDetailsPart2ViewController: UITextFieldDelegate {
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    //find the UITableViewcell superview
    var cell: UIView? = textField;
    while cell != nil && cell?.isKindOfClass(UITableViewCell) == false {
      cell = cell?.superview
    }
    
    //use the UITableViewcell superview to get the NSIndexPath
    if let indexPath = tableView?.indexPathForRowAtPoint(cell?.center ?? CGPointMake(0,0)) {
      if indexPath.row == 1 {
        return string == "" || Int(string) != nil
      }
    }
    
    return true
  }
  
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
      if nextIndex > 2 {
        nextTapped(self)
        return true
      }
      
      let cell = tableView?.cellForRowAtIndexPath(NSIndexPath(forRow: nextIndex, inSection: 0)) as! TextEntryTableViewCell
      cell.textValue?.becomeFirstResponder()
    }
    
    return true
  }
}