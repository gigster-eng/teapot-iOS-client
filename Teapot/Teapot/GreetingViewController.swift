//
//  GreetingViewController.swift
//  Teapot
//
//  Created by Chris on 3/22/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit
import MBProgressHUD

class GreetingViewController: UIViewController {

    @IBOutlet weak var greetingLabel: UILabel!
    var isWaitingForDeepLinkToClose = false
  
    override func viewDidLoad() {
        super.viewDidLoad()

        serverCall()
        // Do any additional setup after loading the view.
    }
  
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    
        if self.isWaitingForDeepLinkToClose == true {
            fireTimer()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func serverCall(){
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        let parameters:[String:AnyObject] = [
            "app": AppConfiguration.appId
        ]
        Connection(configuration: nil).greetingCall(parameters) { [weak self] response, error in
            MBProgressHUD.hideHUDForView(self?.view, animated: true)
          
            if error == nil {
                guard let response = response as? [String:AnyObject] else { return }
                guard let greeting = response["greeting"] as? String else { return }
                dispatch_async(dispatch_get_main_queue()) {
                    print("set greeting!")
                    self?.greetingLabel.text = greeting
                    self?.fireTimer()
                }
            } else {
              // Do not let an error retrieving the greeting block the app from loading
              self?.fireTimer()
            }
        }
    }
    
    func fireTimer(){
        //fire a 3 second timer before we load up rest of app
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(3 * NSEC_PER_SEC)), dispatch_get_main_queue()) {[weak self] () -> Void in
            self?.isWaitingForDeepLinkToClose = self?.presentedViewController != nil
            if self?.isWaitingForDeepLinkToClose == true {
                return
            }
          
            //is the user already logged in?
            let user = User.currentUser
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            if user == nil {
                let auth = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("auth")
                appDelegate.window?.rootViewController = auth
            }else{
                let home = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("home")
                appDelegate.window?.rootViewController = home
            }
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

}
