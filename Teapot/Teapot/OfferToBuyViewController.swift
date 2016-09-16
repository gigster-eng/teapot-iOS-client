//
//  OfferToBuyViewController.swift
//  Teapot
//
//  Created by Matthew Baker on 3/26/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit
import MMNumberKeyboard

class OfferToBuyViewController: UIViewController {
  var item: Item = Item()
  let preferredSize = CGSizeMake(264, 155)
  private var hasSet = false
  
  @IBOutlet weak var offerLabel: UILabel?
  @IBOutlet weak var offerField: UITextField?
  @IBOutlet weak var buyButton: DesignableButton?
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    if hasSet == false {
      hasSet = true
      offerLabel?.text = String(format: "Buy for $%.0f or offer another price", item.price)
      offerField?.text = String(format: "%.0f", item.price)
      
      let keyboard = MMNumberKeyboard(frame: CGRectZero)
      keyboard.allowsDecimalPoint = false
      offerField?.inputView = keyboard
    }
  }
  
  @IBAction func offerToBuyTapped(sender: AnyObject) {
    if let offer = offerField?.text {
      let json = MessageCreationRequest().getJson(String(format: "I would like to buy %@ for %@", item.title, offer), recipientId: item.user.id, listingId: item.listingId ?? "")
      
      buyButton?.setTitle("", forState: .Normal)
      buyButton?.enabled = false
      activityIndicator?.startAnimating()
      
      Connection(configuration: nil).createMessageCall(json, completionBlock: {[weak self] (response, error) -> Void in
        if error != nil {
          print(error.localizedDescription)
          self?.showOKAlertView("Error", message: "Oops, something went wrong. Please give us a few minutes to fix the problem.")
        } else {
          self?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
        
        self?.buyButton?.setTitle("Offer to buy", forState: .Normal)
        self?.buyButton?.enabled = true
        self?.activityIndicator?.stopAnimating()
      })
    }
  }
  
  @IBAction func cancelTapped(sender: AnyObject) {
    self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
  }
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}

extension OfferToBuyViewController: UITextFieldDelegate {
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    return string == "" || Int(string) != nil
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    
    return true
  }
}