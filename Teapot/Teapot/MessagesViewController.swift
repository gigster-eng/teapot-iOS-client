//
//  MessagesViewController.swift
//  Teapot
//
//  Created by Matthew Baker on 3/26/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit
import SlackTextViewController
import MBProgressHUD

class MessagesViewController: SLKTextViewController {
  var listing: Item = Item()
  var messageThread: MessageThread = MessageThread()
  var initialized = false
  var cellContentWidth: CGFloat = 0
  
  class Constants {
    static let OtherCellIdentifier = "OtherCell"
    static let YouCellIdentifier = "YouCell"
  }
  
  override class func tableViewStyleForCoder(decoder: NSCoder) -> UITableViewStyle {
    return .Plain
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    inverted = false
    textInputbar.contentInset = UIEdgeInsetsMake(10.0, 8.0, 10.0, 8.0)
    rightButton.setTitle("   Send   ", forState: .Normal)
    
    if messageThread.listing?.title != nil {
      title = messageThread.listing?.title
    }
  }
  
  override var hidesBottomBarWhenPushed: Bool {
    get {
      return true
    }
    set {
      
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillAppear(animated: Bool) {
    let basicWidth = CGFloat(188.0)
    let sizeDifference = view.bounds.size.width - 320.0
    cellContentWidth = basicWidth + sizeDifference
    navigationController?.navigationBar.applyTheme(.Small)
    
    if initialized == false {
      initialized = true
      
      let otherNib = UINib(nibName: "OtherChatTableViewCell", bundle: nil)
      tableView.registerNib(otherNib, forCellReuseIdentifier: Constants.OtherCellIdentifier)
      let youNib = UINib(nibName: "YouChatTableViewCell", bundle: nil)
      tableView.registerNib(youNib, forCellReuseIdentifier: Constants.YouCellIdentifier)
      tableView.backgroundColor = UIColor(red: 228.0/255.0, green: 230.0/255.0, blue: 224.0/255.0, alpha: 1)
      tableView.tableFooterView = nil
      tableView.separatorStyle = .None
      tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
      
      rightButton.backgroundColor = UIColor.kitGreen()
      rightButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
      rightButton.titleLabel?.font = UIFont(name: "Lato", size: 10)
      rightButton.layer.cornerRadius = 5.0
      
      textView.tintColor = UIColor.kitGreen()
      textView.placeholder = "Message"
      textView.layer.borderWidth = 0
      textInputbar.backgroundColor = UIColor.whiteColor()
      textInputbar.autoHideRightButton = false
    }
    
    if messageThread.threadId != nil {
      let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
      dispatch_after(delayTime, dispatch_get_main_queue()) {
        self.tableView?.slk_scrollToBottomAnimated(true)
      }
    
      return
    }
  
    MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    Connection(configuration: nil).getMessageThreadsCall {[weak self] (response, error) -> Void in
      if error != nil {
        print(error.localizedDescription)
      } else {
        //convert response to array
        guard let threadsJson = response as? [[String:AnyObject]] else {
          print("Could not parse threads response into threads")
          return
        }
        
        if let actualSelf = self {
          for thread in threadsJson {
            if let listingJson = thread["listing"] as? [String: AnyObject] {
              let id = listingJson["listing_id"] as! String?
              if id == actualSelf.listing.listingId {
                Connection(configuration: nil).getMessageThreadCall(thread["message_thread_id"] as! String, completionBlock: {[weak actualSelf] (response, error) -> Void in
                  if error != nil {
                    print(error.localizedDescription)
                    return
                  }
                  
                  if let actualSelf = actualSelf {
                    guard let messageThreadJson = response as? [String:AnyObject] else {
                      print("Could not parse threads response into threads")
                      return
                    }
                    
                    actualSelf.messageThread = MessageThread()
                    actualSelf.messageThread.setFromJson(messageThreadJson)
                    
                    dispatch_async(dispatch_get_main_queue(), {[weak actualSelf] () -> Void in
                      actualSelf?.tableView?.reloadData()
                      actualSelf?.markThreadAsRead()
                      
                      let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
                      dispatch_after(delayTime, dispatch_get_main_queue()) {
                        actualSelf?.tableView.slk_scrollToBottomAnimated(true)
                      }
                      })
                  }
                })
                break
              }
            }
          }
        }
      }
      
      MBProgressHUD.hideHUDForView(self?.view, animated: true)
    }
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    markThreadAsRead()
  }
  
  func markThreadAsRead() {
    for message in messageThread.messages {
      message.read = true
    }
    
    if let listingId = messageThread.listing?.listingId {
      if let otherUserId = messageThread.otherUser?.id {
        Connection(configuration: nil).markMessagesReadCall(listingId, otherUserId: otherUserId) { (response, error) in
          if error != nil {
            print(error.localizedDescription)
          } else {
            print("Thread successfully marked as read")
          }
        }
      }
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    navigationController?.navigationBar.applyTheme(.Normal)
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

extension MessagesViewController {
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let message = messageThread.messages[indexPath.row]
    
    if message.sentByViewer == true {
      let cell = tableView.dequeueReusableCellWithIdentifier(Constants.YouCellIdentifier) as! YouChatTableViewCell
      
      let user = messageThread.viewerUser ?? (User.currentUser ?? User())
      cell.configureWith(message, fromUser: user, width: cellContentWidth)
      
      return cell
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier(Constants.OtherCellIdentifier) as! OtherChatTableViewCell
      
      let user = messageThread.otherUser ?? User()
      cell.configureWith(message, fromUser: user, width: cellContentWidth)
      
      return cell
    }
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messageThread.messages.count
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    let message = messageThread.messages[indexPath.row]
    
    return 42 + message.heightForContent(UIFont(name: "Lato", size: 14) ?? UIFont.kitSystemFontOfSize(14), width: cellContentWidth)
  }
}

extension MessagesViewController {
  override func textViewDidBeginEditing(textView: UITextView) {
    self.tableView.slk_scrollToBottomAnimated(true)
  }
  
  override func didPressRightButton(sender: AnyObject!) {
    textView.refreshFirstResponder()
    
    let request = MessageCreationRequest()
    let json = request.getJson(textView.text, recipientId: messageThread.otherUser?.id ?? (listing.user.id ?? ""), listingId: messageThread.listing?.listingId ?? (listing.listingId ?? ""))
    
    Connection(configuration: nil).createMessageCall(json) { (response, error) -> Void in
      if error != nil {
        print(error.localizedDescription)
      } else {
        print("Message created successfully")
      }
    }
    
    let message = Message()
    message.content = textView.text
    message.sentByViewer = true
    message.read = true
    message.sentAt = NSDate()
    messageThread.messages.append(message)
    
    tableView.beginUpdates()
    tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: messageThread.messages.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Bottom)
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) {
      self.tableView.slk_scrollToBottomAnimated(true)
    }
    tableView.endUpdates()
    
    super.didPressRightButton(sender)
  }
}
