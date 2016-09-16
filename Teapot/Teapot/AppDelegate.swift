//
//  AppDelegate.swift
//  Teapot
//
//  Created by Lin Xuan on 16/02/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Fabric
import Crashlytics
import RealmSwift
import AWSCore
import Branch
import IQKeyboardManager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        applyStyle()

        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        GIDSignIn.sharedInstance().delegate = self
        Fabric.with([Crashlytics.self])
      
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId:AppConfiguration.CognitoPoolId)
      
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialsProvider)
      
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
        
        realmMigrate()
      
        if application.respondsToSelector(#selector(UIApplication.registerUserNotificationSettings(_:))) {
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Sound, .Badge], categories: [])
          UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        } else {
            UIApplication.sharedApplication().registerForRemoteNotifications()
        }
      
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
      
        if ModelManager.sharedManager.getAppID() != "" {
            let params: [String: AnyObject] = [
                "app": AppConfiguration.appId,
                "person_id": ModelManager.sharedManager.getAppID(),
                "source_person_id": ModelManager.sharedManager.getAppID()
            ]
            Connection(configuration: nil).userProfileCall(params) { (response, error) -> Void in
            
                if error == nil {
                    guard let response = response as? [String:AnyObject] else {return}
                    ModelManager.sharedManager.updateUser(response)
                } else {
                    print("error getting user profile: " + error.localizedDescription)
                }
            }
        }
      
        UISegmentedControl.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "Lato-Bold", size: 9.0)!], forState: UIControlState.Normal)
      
        let branch = Branch.getInstance()
        branch.accountForFacebookSDKPreventingAppLaunch()
        if ModelManager.sharedManager.getAppID() != "" {
            let controller = UIStoryboard.init(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("ListingDeepLinkNavigationViewController")
          
            branch.registerDeepLinkController(controller, forKey: "listingId")
        }
      
        branch.initSessionWithLaunchOptions(launchOptions, automaticallyDisplayDeepLinkController: true)
        let greeting = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("greeting")
        self.window?.rootViewController = greeting
      
        self.window?.makeKeyAndVisible()
      
        return true
    }

    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation) ||
                GIDSignIn.sharedInstance().handleURL(url, sourceApplication: sourceApplication, annotation: annotation)
      
        return handled
    }

    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if (error == nil) {
            AuthManager.sharedManager.user = user
            NSNotificationCenter.defaultCenter().postNotificationName(AppConfiguration.LoginSuccess, object: nil)
        } else {
            print("\(error.localizedDescription)")
        }
    }
  
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
        if (error == nil) {
            print("google plus logout success")
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print("Got token data! \(deviceToken)")
        AppConfiguration.deviceToken = deviceToken.description
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Couldn't register: \(error)")
    }
    
    func realmMigrate(){
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 3,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
                if oldSchemaVersion < 3 {
                    migration.enumerate("User", { (oldObject, newObject) -> Void in
                        newObject!["listings"] = List<Item>()
                    })
                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        _ = try! Realm()
    }
    
    func applyStyle() {
        UISegmentedControl.appearance().setTitleTextAttributes([ NSFontAttributeName : UIFont(name: "Lato-Bold",size: 9)! ], forState: .Normal)
        UISegmentedControl.appearance().setTitleTextAttributes([ NSFontAttributeName : UIFont(name: "Lato-Bold",size: 9)! ], forState: .Selected)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.clearColor()], forState: .Normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.clearColor()], forState: .Highlighted)
    }
  
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        Branch.getInstance().continueUserActivity(userActivity)
      
        return true
    }
}

