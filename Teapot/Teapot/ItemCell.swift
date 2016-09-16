//
//  ItemCell.swift
//  Teapot
//
//  Created by Lin Xuan on 16/03/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit
import DateTools

class ItemCell: UICollectionViewCell {
    
    @IBOutlet weak var relation: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var locationWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var categoryWidthConstraint: NSLayoutConstraint!
    var delegate:ItemListingProtocol!
    
    var item: Item? {
        didSet {
            if let item = item {
                title.text = item.title
                
                if item.price > 0 {
                    price.text = "$\(Int(item.price))"
                } else {
                    price.text = "FREE"
                }
                category.text = item.category
                date.text = item.createdAt?.shortTimeAgoSinceNow()
                if item.imageURL != nil {
                    image.sd_setImageWithURL(NSURL(string: item.imageURL!))
                }
                avatar.sd_setImageWithURL(NSURL(string: item.user.profile_picture))
                name.text = item.user.name
                
                let font = UIFont(name: "Lato", size: 8)!
                let categoryWidth = item.widthForCategory(font, height: 13)
                
                location.text = "\(item.location.city), \(item.location.state)"
              
                relation.hidden = false
                if let trustGraph = item.user.trustGraph {
                    if let distance = trustGraph.distance {
                        if distance == 0 || distance == 6 {
                            relation.hidden = true
                        } else {
                            relation.text = String(format: "%ld%@", distance, distance.numberSuffix())
                        }
                    }
                }

                let locationWidth = item.widthForLocation(font, height: 13)
                locationWidthConstraint.constant = locationWidth + 10
                categoryWidthConstraint.constant = categoryWidth + 10
                contentView.layoutIfNeeded()
            }
        }
    }
    
    override func prepareForReuse() {
        image.image = nil
        avatar.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        relation.layer.cornerRadius = relation.frame.width / 2
        relation.backgroundColor = UIColor.kitGreen()
        avatar.layer.cornerRadius = avatar.frame.size.width / 2
        avatar.clipsToBounds = true
        title.textColor = UIColor.kitBlack66()
        name.textColor = UIColor.kitBlack117()
        location.textColor = UIColor.kitBlack189()
        location.layer.borderColor = UIColor.kitGreen().CGColor
        location.layer.borderWidth = 1
        location.layer.cornerRadius = 5
        location.clipsToBounds = true
        price.textColor = UIColor.kitGreen()
        category.backgroundColor = UIColor.kitBlue()
        category.layer.cornerRadius = 5
        category.clipsToBounds = true
        date.textColor = UIColor.kitBlack117()
        let tapGesture = UITapGestureRecognizer(target: self, action: "categoryTapped:")
        category.addGestureRecognizer(tapGesture)
        category.userInteractionEnabled = true
        let locationTapGesture = UITapGestureRecognizer(target: self, action: "locationTapped:")
        location.addGestureRecognizer(locationTapGesture)
        location.userInteractionEnabled = true
    }
    
    func categoryTapped(sender: UITapGestureRecognizer){
        delegate.didTapCategory(category.text ?? "")
    }
    func locationTapped(sender: UITapGestureRecognizer){
        delegate.didTapLocation(item!.location)
    }
}
