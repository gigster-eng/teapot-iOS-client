//
//  IntroViewController.swift
//  Hedgeable
//
//  Created by Lin Gang Xuan on 17/01/16.
//  Copyright © 2016 Hedgeable. All rights reserved.
//

import UIKit
import JazzHands

class IntroViewController: IFTTTAnimatedScrollViewController {
    struct Constants {
        static let NumberOfPages: Int = 3
    }

    private func timeForPage(page: CGFloat) -> CGFloat {
        return view.frame.size.width * (page - 1)
    }

    var pageControl:UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addScrollView()
        addPageControl()
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    private func addPageControl() {
        let pageControl = UIPageControl(frame: CGRectMake(0, view.frame.size.height - 50, view.frame.width, 44))
        pageControl.numberOfPages = 3
        pageControl.currentPage = 0
        pageControl.userInteractionEnabled = false
        pageControl.currentPageIndicatorTintColor = UIColor.whiteColor()
        pageControl.pageIndicatorTintColor = UIColor.blackColor()
        self.pageControl = pageControl
        view.addSubview(pageControl)
    }

    private func addScrollView() {
        scrollView.contentSize = CGSizeMake(CGFloat(Constants.NumberOfPages) * view.frame.size.width, view.frame.size.height)
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        
        buildViews()
        //configureAnimations()
    }
    
    private func buildViews() {
        buildView1()
        buildView2()
        buildView3()
    }
    
    private func buildView1() {
        let imageView = UIImageView(image: UIImage(assetIdentifier: .TutorialImage1))
        imageView.frame = CGRectMake(0, 0, view.frame.width, view.frame.height)
        scrollView.addSubview(imageView)
        
        let font = UIFont(name: "Lato-Black", size: 18)!
        let label = buildLabel("Stuff for sale from  \nmoms near you", textColor: UIColor.whiteColor(), numberOfLines: 2, sizeTofit: true, font: font)
        label.center = view.center
        label.frame = CGRectOffset(label.frame, 0, 150)
        scrollView.addSubview(label)
    }
    
    private func buildView2() {
        let page: CGFloat = 2

        let imageView = UIImageView(image: UIImage(assetIdentifier: .TutorialImage2))
        imageView.frame = CGRectMake(0, 0, view.frame.width, view.frame.height)
        imageView.frame = CGRectOffset(imageView.frame, timeForPage(page), 0)
        scrollView.addSubview(imageView)
        
        let font = UIFont(name: "Lato-Black", size: 18)!
        let label = buildLabel("Find a new home for your stuff", textColor: UIColor.whiteColor(), numberOfLines: 2, sizeTofit: true, font: font)
        label.center = view.center
        label.frame = CGRectOffset(label.frame, timeForPage(page), 150)

        scrollView.addSubview(label)
    }
    
    private func buildView3() {
        let page: CGFloat = 3

        let imageView = UIImageView(image: UIImage(assetIdentifier: .TutorialImage3))
        imageView.frame = CGRectMake(0, 0, view.frame.width, view.frame.height)
        imageView.frame = CGRectOffset(imageView.frame, timeForPage(page), 0)
        scrollView.addSubview(imageView)
        
        let font = UIFont(name: "Lato-Black", size: 18)!
        let label = buildLabel("Buy from other moms in  \nyour social circle", textColor: UIColor.whiteColor(), numberOfLines: 2, sizeTofit: true, font: font)
        label.center = view.center
        label.frame = CGRectOffset(label.frame, timeForPage(page), 150)

        scrollView.addSubview(label)
        
        let signupButton = UIButton(type: .System)
        signupButton.backgroundColor = UIColor.kitGreen()
        signupButton.frame = CGRectMake(0, 0, 82, 26)
        signupButton.setTitle("Sign Up", forState: .Normal)
        signupButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        signupButton.titleLabel?.font = UIFont(name: "Lato", size: 15)
        signupButton.center = CGPointMake(timeForPage(page) + view.frame.size.width - 61, view.frame.size.height - 30)
        signupButton.addTarget(self, action: "onSignup:", forControlEvents: .TouchUpInside)
        
        scrollView.addSubview(signupButton)
        
    }
    
    func onSignup(sender: UIButton) {
        performSegueWithIdentifier("login", sender: self)
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let currentPage = currentScrollVIewIndex()
        pageControl.currentPage = Int(currentPage)
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let currentPage = currentScrollVIewIndex()
            pageControl.currentPage = Int(currentPage)
        }
    }
    
    private func currentScrollVIewIndex() -> CGFloat {
        let pageWidth = scrollView.frame.size.width
        let index = scrollView.contentOffset.x / pageWidth
        return index
    }
        
    private func buildLabel(text: String, textColor: UIColor, numberOfLines: Int, sizeTofit: Bool, font: UIFont) -> UILabel {
        let label = UILabel()
        
        label.font = font
        label.textAlignment = .Center
        label.text = text
        label.textColor = textColor
        label.numberOfLines = numberOfLines
        if sizeTofit {
            label.sizeToFit()
        }
        return label
    }
    
    func onSignUp() {
        performSegueWithIdentifier("signUp", sender: self)
    }
}
