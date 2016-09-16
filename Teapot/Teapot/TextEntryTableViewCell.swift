//
//  TextEntryTableViewCell.swift
//  Teapot
//
//  Created by Matthew Baker on 3/18/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit
import MMNumberKeyboard

class TextEntryTableViewCell: UITableViewCell {
  
  @IBOutlet weak var textValue: UITextField?
  @IBOutlet weak var leadingLabel: UILabel?
  @IBOutlet weak var leadingLabelRightConstraint: NSLayoutConstraint?
  @IBOutlet weak var leadingLabelWidthConstraint: NSLayoutConstraint?
  
  private var pickListItems: [String] = []
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func setup(placeholder: String, keyboardType: UIKeyboardType, delegate: UITextFieldDelegate, leadingLabelText: String?, pickListItems: [String]) {
    textValue?.placeholder = placeholder
    textValue?.delegate = delegate
    textValue?.keyboardType = keyboardType
    
    textValue?.returnKeyType = .Next
    if leadingLabelText == nil || leadingLabelText?.characters.count == 0 {
      leadingLabel?.hidden = true
      leadingLabelRightConstraint?.constant = 0
      leadingLabelWidthConstraint?.constant = 0
    } else {
      leadingLabel?.hidden = false
      leadingLabelRightConstraint?.constant = 8.0
      leadingLabelWidthConstraint?.constant = 10.5
    }
    
    self.pickListItems = pickListItems
    if pickListItems.count > 0 {
      let picker = UIPickerView()
      picker.delegate = self
      picker.dataSource = self
      textValue?.inputView = picker
    } else {
      textValue?.inputView = nil
    }
    
    if keyboardType == UIKeyboardType.NumberPad {
      let keyboard = MMNumberKeyboard(frame: CGRectZero)
      keyboard.allowsDecimalPoint = false
      keyboard.delegate = self
      textValue?.inputView = keyboard
    }
    
    layoutIfNeeded()
  }
  
  var inputValue: String? {
    get {
      return textValue?.text
    }
    set {
      textValue?.text = newValue
    }
  }
}

extension TextEntryTableViewCell: MMNumberKeyboardDelegate {
  func numberKeyboardShouldReturn(numberKeyboard: MMNumberKeyboard!) -> Bool {
    if let delegate = textValue?.delegate {
      return delegate.textFieldShouldReturn!(textValue!)
    }
    
    return true
  }
}

extension TextEntryTableViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return pickListItems.count
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return pickListItems[row]
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    textValue?.text = pickListItems[row]
    if let delegate = textValue?.delegate {
      delegate.textFieldShouldReturn!(textValue!)
    }
  }
}