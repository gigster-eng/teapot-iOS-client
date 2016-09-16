//
//  ProfileCell.swift
//  Teapot
//
//  Created by Lin Xuan on 08/03/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit

class ProfileCell: UITableViewCell {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var joinedDate: UILabel!
    
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var fullnameTxt: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var fulllocationLabel: UILabel!
    @IBOutlet weak var fulllocationTxt: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        name.textColor = UIColor.kitGreen()
        fullnameLabel.textColor = UIColor.kitGreen()
        emailLabel.textColor = UIColor.kitGreen()
        fulllocationLabel.textColor = UIColor.kitGreen()
        photo.layer.cornerRadius = photo.frame.width / 2
        photo.clipsToBounds = true
        
        if let user = User.currentUser {
            name.text = user.name
            fullnameTxt.text = user.name
            emailTxt.text = user.email
            if let photoURL = NSURL(string: user.profile_picture) {
                photo.sd_setImageWithURL(photoURL)
            }
        }
    }
}
