//
//  MessageThreadTableViewHeader.swift
//  Teapot
//
//  Created by Matthew Baker on 3/30/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit

protocol MessageThreadTableViewHeaderDelegate {
  func messageThreadHeaderTapped(header: MessageThreadTableViewHeader)
}

class MessageThreadTableViewHeader: UIView {
  // Our custom view from the XIB file
  var view: UIView?
  var delegate: MessageThreadTableViewHeaderDelegate? = nil
  
  class Constants {
    static let MessageThreadTableViewHeaderNib = "MessageThreadTableViewHeader"
    
    static let TitleTag = 1
    static let CountTag = 2
    static let ImageTag = 3
    static let DownChevronTag = 4
    static let RightChevronTag = 5
  }
  
  override init(frame: CGRect) {
    // 1. setup any properties here
    
    // 2. call super.init(frame:)
    super.init(frame: frame)
    
    // 3. Setup view from .xib file
    xibSetup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    // 1. setup any properties here
    
    // 2. call super.init(coder:)
    super.init(coder: aDecoder)
    
    // 3. Setup view from .xib file
    xibSetup()
  }
  
  func xibSetup() {
    view = loadViewFromNib()
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(MessageThreadTableViewHeader.viewTapped))
    tap.enabled = true
    addGestureRecognizer(tap)
    
    // use bounds not frame or it'll be offset
    view?.frame = bounds
    
    // Make the view stretch with containing view
    view?.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
    
    // Adding custom subview on top of our view (over any custom drawing > see note below)
    addSubview(view!)
  }
  
  func loadViewFromNib() -> UIView {
    let nib = UINib(nibName: Constants.MessageThreadTableViewHeaderNib, bundle: nil)
    let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
    
    return view
  }
  
  func viewTapped() {
    let closed = view?.viewWithTag(Constants.RightChevronTag)?.hidden
    view?.viewWithTag(Constants.RightChevronTag)?.hidden = closed == false
    view?.viewWithTag(Constants.DownChevronTag)?.hidden = closed == true
    
    delegate?.messageThreadHeaderTapped(self)
  }
  
  func configureWith(title: String, unreadCount: Int, imageUrl: NSURL?, expanded: Bool) {
    (view?.viewWithTag(Constants.TitleTag) as? UILabel)?.text = title
    
    if unreadCount == 0 {
      view?.viewWithTag(Constants.CountTag)?.hidden = true
    } else {
      if let countView = view?.viewWithTag(Constants.CountTag) as? UILabel {
        countView.hidden = false
        countView.text = String(format: "(%ld)", unreadCount)
      }
    }
    
    if let imageView = view?.viewWithTag(Constants.ImageTag) as? UIImageView {
      imageView.sd_cancelCurrentImageLoad()
      imageView.image = nil
      
      if let url = imageUrl {
        imageView.sd_setImageWithURL(url)
      }
    }
    
    view?.viewWithTag(Constants.RightChevronTag)?.hidden = expanded == true
    view?.viewWithTag(Constants.DownChevronTag)?.hidden = expanded == false
  }
  
}
