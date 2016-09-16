//
//  ListingDeepLinkNavigationViewController.swift
//  Teapot
//
//  Created by Matthew Baker on 3/30/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit
import Branch

class ListingDeepLinkNavigationViewController: NavigationController {
  
  weak public var deepLinkingCompletionDelegate: BranchDeepLinkingControllerCompletionDelegate! {
    didSet {
      (viewControllers.first as? ListingDetailsViewController)?.deepLinkingCompletionDelegate = deepLinkingCompletionDelegate
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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

extension ListingDeepLinkNavigationViewController: BranchDeepLinkingController {
  func configureControlWithData(data: [NSObject : AnyObject]!) {
    if let root = viewControllers.first as? ListingDetailsViewController {
      root.configureControlWithData(data)
    } else {
      deepLinkingCompletionDelegate.deepLinkingControllerCompleted()
    }
  }
}
