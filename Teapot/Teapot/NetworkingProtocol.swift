//
//  NetworkingErrorProtocol.swift
//  jitjatjo
//
//  Created by Lin Xuan on 21/03/16.
//  Copyright © 2016 jitjatjo. All rights reserved.
//

import Foundation
import MBProgressHUD

protocol NetworkingProtocol: class {
}

extension NetworkingProtocol where Self: UIViewController {


    func showLoader() {
        MBProgressHUD.showHUDAddedTo(view, animated: true)
    }
    
    func hideLoader() {
        MBProgressHUD.hideHUDForView(view, animated: true)
    }
    
    func handlerResponse(response: AnyObject) {
        print(response)
    }
    
    func handlerError(error: NSError) {
        print(error.localizedDescription)
      
        showOKAlertView(nil, message: "Oops, something went wrong. Please give us a few minutes to fix the problem.")
    }
}