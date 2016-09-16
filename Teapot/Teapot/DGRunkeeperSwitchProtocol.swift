//
//  DGRunkeeperSwitchProtocol.swift
//  Teapot
//
//  Created by Lin Xuan on 27/03/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import Foundation
import DGRunkeeperSwitch

protocol DGRunkeeperSwitchProtocol {
    
}

extension DGRunkeeperSwitchProtocol where Self: UIViewController {
    func getDGRunkeeperSwitch(leftTitle: String, rightTitle: String) -> DGRunkeeperSwitch {
        let runkeeperSwitch = DGRunkeeperSwitch(leftTitle: leftTitle, rightTitle: rightTitle)
        runkeeperSwitch.backgroundColor = UIColor.kitDarkGreen()
        runkeeperSwitch.selectedBackgroundColor = UIColor.kitGreen()
        runkeeperSwitch.titleColor = .whiteColor()
        runkeeperSwitch.selectedTitleColor = .whiteColor()
        runkeeperSwitch.titleFont = UIFont(name: "Lato-Bold", size: 9)
        runkeeperSwitch.frame = CGRect(x: 50.0, y: 20.0, width: view.bounds.width - 100.0, height: 30.0)
        runkeeperSwitch.autoresizingMask = [.FlexibleWidth]
        
        return runkeeperSwitch
    }
}