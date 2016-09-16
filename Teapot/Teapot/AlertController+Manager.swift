//
//  AlertController+Manager.swift
//  Teapot
//
//  Created by Chris on 2/24/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit

extension UIViewController {
    func showOKAlertView(title: String?, message: String?) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alertView, animated: true, completion: nil)
    }
}