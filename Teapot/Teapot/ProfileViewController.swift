//
//  ProfileViewController.swift
//  Teapot
//
//  Created by Lin Xuan on 08/03/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    struct Constant {
        static let ProfileCell = "ProfileCell"
    }
    
    @IBOutlet weak var tableView: TableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.kitBackground()
        
        tableView.registerNib(UINib(nibName: Constant.ProfileCell, bundle: nil), forCellReuseIdentifier: Constant.ProfileCell)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.keyboardDismissMode = .Interactive
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constant.ProfileCell, forIndexPath: indexPath)
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 298
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}
