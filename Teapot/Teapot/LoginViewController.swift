//
//  LoginViewController.swift
//  Teapot
//
//  Created by Lin Xuan on 22/02/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit
import APAddressBook
import MBProgressHUD
import CoreLocation

class LoginViewController: UIViewController, GIDSignInUIDelegate {
    @IBOutlet weak var contactReason: UILabel!
    
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googlePlusButton: UIButton!
    var providers = [String]()
    var chosenProvider:String = ""
    
    var manager: OneShotLocationManager = OneShotLocationManager()
    
    let addressBook = APAddressBook()
    var contacts = [APContact]()
    var location: CLLocation?

    @IBAction func onGoogle(sender: AnyObject) {
        chosenProvider = "google_plus"
        GIDSignIn.sharedInstance().scopes = [
            "email",
            "profile",
            "https://www.googleapis.com/auth/plus.login",
            "https://www.googleapis.com/auth/plus.profile.emails.read",
            "openid",
            "https://www.googleapis.com/auth/plus.me",
            "https://www.googleapis.com/auth/contacts.readonly"
        ]
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func onFacebook(sender: AnyObject) {
        chosenProvider = "facebook"
        
        FacebookManager.defaultManager().getReadSessionToken { (token) -> Void in
            FacebookManager.defaultManager().getLoggedUserInfo { (result, error) -> Void in
                if error == nil {
                    print(result)
                    guard let id = result["id"] as? String else {return}
                    AuthManager.sharedManager.fbUser = FacebookUser(access_token: FBSDKAccessToken.currentAccessToken().tokenString, id: id)
                    self.onLogin()
                }else{
                    print(error)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: "onReason:")
        contactReason.addGestureRecognizer(tap)
        contactReason.userInteractionEnabled = true
        GIDSignIn.sharedInstance().uiDelegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onLogin", name: AppConfiguration.LoginSuccess, object: nil)
        
        //get login providers
        getProviderCall()
        
        //get contacts
        getContacts()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func getProviderCall() {
        let parameters = [
            "device_token": AppConfiguration.deviceToken,
            "app": AppConfiguration.appId
        ]
        
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        Connection(configuration: nil).loginProvidersCall(parameters) { [weak self] response, error in
            MBProgressHUD.hideHUDForView(self?.view, animated: true)
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    print("Got login providers!")
                    print(response)
                    if let response = response as? [String:AnyObject] {
                        if let providers = response["providers"] as? [String] {
                            self?.providers = providers
                            var facebookFound = false
                            var googlePlusFound = false
                            for provider in providers {
                                //turn off providers that aren't returned
                                if provider == "facebook" {
                                    facebookFound = true
                                }else if provider == "google_plus" {
                                    googlePlusFound = true
                                }
                            }
                            if facebookFound {
                                //show FB button
                                self?.facebookButton.hidden = false
                            }
                            
                            if googlePlusFound {
                                //show GP button
                                self?.googlePlusButton.hidden = false
                            }
                        }
                    }
                }
            } else {
                self?.showOKAlertView(nil, message: "Oops, something went wrong. Please give us a few minutes to fix the problem.")
            }
        }
    }
    
    func onReason(gesture: UITapGestureRecognizer) {
        print("reason")
    }
    
    func onLogin() {
        if !providers.contains(chosenProvider) {
            print("Invalid provider!  You are trying to login using \(chosenProvider) but only \(providers) are allowed")
            return
        }
        var parameters:[String:AnyObject]?
        if let user = AuthManager.sharedManager.user {
            
            parameters = [
                "app": AppConfiguration.appId,
                "access_token" : user.authentication.accessToken,
                "refresh_token" : user.authentication.refreshToken,
                "provider": chosenProvider,
                "uid": user.userID,
                "unencrypted_payload": [
                    "ios_data_payload": getDataPayload()
                ]
            ]
            
//            print("id token: \(user.authentication.idToken)")
            
        }else if let user = AuthManager.sharedManager.fbUser {
            parameters = [
                "app": AppConfiguration.appId,
                "access_token" : user.access_token,
                "provider": chosenProvider,
                "uid": user.id,
                "unencrypted_payload": [
                    "ios_data_payload": getDataPayload()
                ]
            ]
        }
        
        guard let params = parameters else {return}
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        Connection(configuration: nil).registerCall(params as [NSObject : AnyObject]) { [weak self] response, error in
            MBProgressHUD.hideHUDForView(self?.view, animated: true)
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    print("Auth success! ")
                    print(response)
                    //parse response
                    guard let response = response as? [String:AnyObject] else {return}
                    ModelManager.sharedManager.updateUser(response)
                  
                    let params: [String: AnyObject] = [
                        "app": AppConfiguration.appId,
                        "person_id": ModelManager.sharedManager.getAppID(),
                        "source_person_id": ModelManager.sharedManager.getAppID()
                    ]
                  
                    // Pull the user's full profile in order to get their listings
                    Connection(configuration: nil).userProfileCall(params) { (response, error) -> Void in
                        if error == nil {
                            guard let response = response as? [String:AnyObject] else {return}
                            ModelManager.sharedManager.updateUser(response)
                        } else {
                            print("error getting user profile: " + error.localizedDescription)
                        }
                    }
                  
                    self?.goHome()
                }
            } else {
                self?.showOKAlertView(nil, message: "Oops, something went wrong. Please give us a few minutes to fix the problem.")
            }
        }
    }
    
    func goHome() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("home")
        UIView.transitionWithView(view.window!, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.view.window!.rootViewController = vc
            }, completion: nil)
    }
    
    func getContacts() {
        //show only contacts with phone numbers.  turned off because they want all contacts.
//        self.addressBook.filterBlock = {
//            (contact: APContact) -> Bool in
//            if let phones = contact.phones {
//                return phones.count > 0
//            }
//            return false
//        }
        addressBook.fieldsMask = APContactField.All
        addressBook.sortDescriptors = [
            NSSortDescriptor(key: "name.firstName", ascending: true),
            NSSortDescriptor(key: "name.lastName", ascending: true)
        ]
        addressBook.loadContacts(
            { (contacts: [APContact]?, error: NSError?) in
                if let unwrappedContacts = contacts {
                    // show pointless extra dialog that was specifically requested by client
                    let secondAlert = UIAlertController(title: "Send contacts to Teapot's server?", message: "To show you items posted by moms in your social circle, we need to store your contacts on our servers. Don't worry, they will be sent and stored securely and we won't share them with anyone.", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    secondAlert.addAction(UIAlertAction(title: "Don't Allow", style: .Default, handler: { (action: UIAlertAction!) in
                        self.getLocation()
                    }))
                    
                    secondAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
                        self.contacts = unwrappedContacts
                        self.getLocation()
                    }))
                    
                    self.presentViewController(secondAlert, animated: true, completion: nil)
                    
                }
                else if let unwrappedError = error {
                    // show error
                    print("Error getting contacts")
                    print(unwrappedError)
                }
        })
    }
    
    func getLocation(){
        manager.fetchWithCompletion {location, error in
            // fetch location or an error
            if let loc = location {
                self.location = loc
            } else if let err = error {
                self.showOKAlertView("Error", message: err.localizedDescription)
            }
        }
    }
    
    func formatContacts() -> [[String:AnyObject]]{
        //convert contacts into userContacts format for sending to server
        var userContacts = [[String:AnyObject]]()
        
        for contact in contacts {
//            print(contact)
            let aContact:[String:AnyObject] = [
                "name": contact.name?.compositeName ?? "NoNameFound",
                "phone_numbers": (contact.phones ?? []).map({ (phone) -> String in
                    return phone.number ?? "NoNumberFound"
                }),
                "emails": (contact.emails ?? []).map({ (email) -> String in
                    return email.address! ?? "NoEmailFound"
                })
            ]
            userContacts.append(aContact)
        }
        return userContacts
    }
    
    func getDataPayload() -> [String:AnyObject]{
        let userContacts = formatContacts()
        
        let data_payload:[String:AnyObject] = [
            "device_token": AppConfiguration.deviceToken,
            "user_profile": [
                "primary_phone_number": "",
                "location": [location?.coordinate.latitude ?? 512, location?.coordinate.longitude ?? 512]
            ],
            "contacts": userContacts
        ]
        
        return data_payload
    }
}
