//
//  FriendsViewController.swift
//  Teapot
//
//  Created by Matthew Baker on 5/30/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit
import MBProgressHUD
import APAddressBook
import Branch
import MessageUI

class FriendsViewController: UITableViewController, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, FriendTableViewCellDelegate {
  
  let addressBook = APAddressBook()
  var users: [User] = []
  var sections = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
  
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
    
    MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    Connection(configuration: nil).friendsListCall(ModelManager.sharedManager.getAppID()) {[weak self] (response, error) in
      if error != nil {
        print(error.localizedDescription)
        return
      }
      
      print(response)
      //convert response to array
      guard let usersArray = response as? [[String:AnyObject]] else {
        print("Could not parse friends response into users")
        return
      }
      
      self?.users = []
      for itemJson in usersArray {
        let user = User()
        user.setFromJson(itemJson)
        self?.users.append(user)
      }
      
      dispatch_async(dispatch_get_main_queue(), {[weak self] () -> Void in
        self?.tableView.reloadData()
        
        MBProgressHUD.hideHUDForView(self?.view, animated: true)
        })
    }
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return sections.count
  }
  
  override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
    return nil
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return sections[section]
  }
  
  override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
    return index
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let sectionArray = users.filter() { $0.first_name.hasPrefix(sections[section]) }
    
    return sectionArray.count
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    let cell = tableView.cellForRowAtIndexPath(indexPath) as? FriendTableViewCell
    
    if let user = cell?.user {
      performCellAction(user);
    }
  }
  
  func performCellAction(user: User) {
    if user.isAppUser == true {
      performSegueWithIdentifier("FriendDetailSegue", sender: user)
    } else {
      let branchUniversalObject: BranchUniversalObject = BranchUniversalObject()
      branchUniversalObject.title = "Teapot App"
      branchUniversalObject.contentDescription = "Join me on Teapot"
      
      let linkProperties: BranchLinkProperties = BranchLinkProperties()
      linkProperties.feature = "invite"
      linkProperties.addControlParam("invitingUserId", withValue: ModelManager.sharedManager.getAppID())
      
      branchUniversalObject.getShortUrlWithLinkProperties(linkProperties,  andCallback: {[weak self] (url: String?, error: NSError?) -> Void in
        if error == nil {
          print(String(format: "got my Branch link to share: %@", url ?? ""))
          
          let string = String(format: "Hi there, have you tried Teapot yet? I think you'd like it...%@", url ?? "")
          
          self?.shareWithUser(user, body: string)
        }
        })
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "FriendDetailSegue" {
      let vc = segue.destinationViewController as! FriendDetailViewController
      vc.user = sender as! User
    }
  }
  
  func shareWithUser(user: User, body: String) {
      //show only contacts with phone numbers.  turned off because they want all contacts.
              self.addressBook.filterBlock = {
                  (contact: APContact) -> Bool in
                  var mobile: String? = nil
                  var emailMatches = false
                
                  for phone in contact.phones ?? [] {
                    if phone.localizedLabel == "mobile" {
                      mobile = phone.number
                      break
                    }
                  }
                
                  for email in contact.emails ?? [] {
                    if email.address == user.email {
                      emailMatches = true
                      break
                    }
                  }
                
                  return mobile != nil && emailMatches
              }
      addressBook.fieldsMask = APContactField.All
      addressBook.sortDescriptors = [
        NSSortDescriptor(key: "name.firstName", ascending: true),
        NSSortDescriptor(key: "name.lastName", ascending: true)
      ]
      addressBook.loadContacts(
        { (contacts: [APContact]?, error: NSError?) in
          if let unwrappedContacts = contacts {
            if let contact = unwrappedContacts.first {
              var mobile: String? = nil
              for phone in contact.phones ?? [] {
                if phone.localizedLabel == "mobile" {
                  mobile = phone.number
                  break
                }
              }
              
              if mobile != nil {
                // Send text
                self.shareViaText(mobile!, email: user.email ?? "", body: body)
              } else {
                // Send email
                self.shareViaEmail(user.email ?? "", body: body)
              }
            } else {
              // Send email
              self.shareViaEmail(user.email ?? "", body: body)
            }
          }
          else if let unwrappedError = error {
            // show error
            print("Error getting contacts")
            print(unwrappedError)
            
            // Send email
            self.shareViaEmail(user.email ?? "", body: body)
          }
      })
  }
  
  func shareViaEmail(email: String, body: String) {
    if (MFMailComposeViewController.canSendMail() == false) {
      return
    }
    
    let mailComposer = MFMailComposeViewController()
    mailComposer.setMessageBody(body, isHTML: false)
    mailComposer.mailComposeDelegate = self
    mailComposer.setSubject("Join me on Teapot?")
    mailComposer.setToRecipients([email])
    self.presentViewController(mailComposer, animated: true, completion: nil)
  }
  
  func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func shareViaText(phone: String, email: String, body: String) {
    if (MFMessageComposeViewController.canSendText()) {
      let messageComposer = MFMessageComposeViewController()
      messageComposer.body = body
      messageComposer.messageComposeDelegate = self;
      messageComposer.recipients = [phone]
      self.presentViewController(messageComposer, animated: true, completion: nil)
    } else {
      shareViaEmail(email, body: body)
    }
  }
  
  func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 18.0
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("FriendTableViewCell") as? FriendTableViewCell
    
    let sectionArray = users.filter() { $0.first_name.hasPrefix(sections[indexPath.section]) }
    let user = sectionArray[indexPath.row];
    
    cell?.delegate = self
    cell?.setForUser(user)
    
    return cell ?? UITableViewCell()
  }
  
  func detailTapped(user: User) {
    performCellAction(user)
  }

}
