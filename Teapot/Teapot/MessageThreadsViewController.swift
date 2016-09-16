//
//  MessageThreadsViewController.swift
//  Teapot
//
//  Created by Matthew Baker on 3/30/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit
import MBProgressHUD

class MessageThreadsViewController: UIViewController {
  var listingIds: [String] = []
  var expandedSections: [Int] = [0]
  var listingThreads: [String:[MessageThread]] = [:]
  
  @IBOutlet weak var tableView: UITableView?
  
  class Constants {
    static let MessageThreadTableViewCellIdentifier = "MessageThreadTableViewCell"
    static let MessageThreadTableViewHeaderNib = "MessageThreadTableViewHeader"
    static let MessageThreadSegueIdentifier = "MessageThreadSegue"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    tableView?.tableFooterView = UIView()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.applyTheme(.Small)

    if listingIds.count != 0 {
      tableView?.reloadData()
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
          let group = dispatch_group_create()
          
          print(String(threadsJson.count) + " threads to get")
          if threadsJson.count > 0 {
            for index in 0...threadsJson.count-1 {
              let thread = threadsJson[index]
              if let listingJson = thread["listing"] as? [String: AnyObject] {
                if let id = listingJson["listing_id"] as? String {
                  if actualSelf.listingThreads[id] == nil {
                    actualSelf.listingIds.append(id)
                    actualSelf.listingThreads[id] = []
                  }
                  
                  dispatch_group_enter(group)
                  print("Getting thread for " + (thread["message_thread_id"] as! String))
                  
                  Connection(configuration: nil).getMessageThreadCall(thread["message_thread_id"] as! String, completionBlock: {[weak actualSelf] (response, error) -> Void in
                    if error != nil {
                      print(error.localizedDescription)
                      dispatch_group_leave(group)
                      return
                    }
                    
                    if let actualSelf = actualSelf {
                      guard let messageThreadJson = response as? [String:AnyObject] else {
                        print("Could not parse threads response into threads")
                        dispatch_group_leave(group)
                        return
                      }
                      
                      let messageThread = MessageThread()
                      messageThread.setFromJson(messageThreadJson)
                      actualSelf.listingThreads[id]?.append(messageThread)
                      
                      print ("Got thread for " + messageThread.threadId!)
                      dispatch_group_leave(group)
                    }
                    })
                }
              }
            }
          }
          else {
            dispatch_group_enter(group)
            dispatch_group_leave(group)
          }
          
          dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { 
            dispatch_async(dispatch_get_main_queue(), {[weak actualSelf] () -> Void in
              print("Got all threads!")
              var toRemove: [String] = []
              if let listingIds = actualSelf?.listingIds {
                for id in listingIds {
                  if actualSelf?.listingThreads[id]?.count == 0 {
                    toRemove.append(id)
                  }
                }
                
                for id in toRemove {
                  actualSelf?.listingThreads[id] = nil
                  if let index = actualSelf?.listingIds.indexOf(id) {
                    actualSelf?.listingIds.removeAtIndex(index)
                  }
                }
              }
              
              MBProgressHUD.hideHUDForView(self?.view, animated: true)
              actualSelf?.tableView?.reloadData()
              })
          })
        }
      }
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    navigationController?.navigationBar.applyTheme(.Normal)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == Constants.MessageThreadSegueIdentifier {
      let vc = segue.destinationViewController as! MessagesViewController
      vc.messageThread = sender as! MessageThread
    }
  }
}

extension MessageThreadsViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let messageThread = listingThreads[listingIds[indexPath.section]]![indexPath.row]
    let cell = tableView.dequeueReusableCellWithIdentifier(Constants.MessageThreadTableViewCellIdentifier) as! MessageThreadTableViewCell
    
    cell.configureWithMessageThread(messageThread)
    
    return cell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return listingThreads[listingIds[section]]!.count
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return listingIds.count
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 59.0
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = MessageThreadTableViewHeader(frame: CGRectMake(0, 0, view.frame.size.width, 59.0))
    
    let listingId = listingIds[section]
    
    var unreadCount = 0
    var listingTitle: String? = ""
    var listingImage: NSURL? = nil
    if let threads = listingThreads[listingId] {
      for thread in threads {
        listingTitle = thread.listing?.title
        listingImage = NSURL(string: thread.listing?.imageURL ?? "")
        for message in thread.messages {
          if message.sentByViewer == false && message.read == false {
            unreadCount += 1
          }
        }
      }
      
      header.configureWith(listingTitle ?? "", unreadCount: unreadCount, imageUrl: listingImage, expanded: expandedSections.contains(section))
      header.delegate = self
      header.tag = section
      
      return header
    }
    
    return nil
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    let listingId = listingIds[indexPath.section]
    if let thread = listingThreads[listingId]?[indexPath.row] {
      performSegueWithIdentifier(Constants.MessageThreadSegueIdentifier, sender: thread)
    }
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if expandedSections.contains(indexPath.section) {
      return 59.0
    }
    
    return 0
  }
}

extension MessageThreadsViewController: MessageThreadTableViewHeaderDelegate {
  func messageThreadHeaderTapped(header: MessageThreadTableViewHeader) {
    let section = header.tag
    
    if expandedSections.contains(section) {
      if let index = expandedSections.indexOf(section) {
        expandedSections.removeAtIndex(index)
      }
    } else {
      expandedSections.append(section)
    }
    
    tableView?.beginUpdates()
    tableView?.endUpdates()
  }
}