//
//  BrowseViewController.swift
//  Teapot
//
//  Created by Lin Xuan on 16/03/16.
//  Copyright © 2016 Teapot. All rights reserved.
//

import UIKit
import AVFoundation
import MBProgressHUD
import DGRunkeeperSwitch

protocol ItemListingProtocol {
    func didTapCategory(category: String)
    func didTapLocation(location: Location)
}

class BrowseViewController: UIViewController, NetworkingProtocol, DGRunkeeperSwitchProtocol {

    struct Constant {
        static let ItemCell = "ItemCell"
        static let ListingDetailsSegueIdentifier = "ListingDetailsSegue"
      
        static let CollectionViewTopPadding: CGFloat = 10
        static let MaxLabelHeight: CGFloat = 47.0
    }
    
    var filtersEnabled = true
    
    var oldInset:UIEdgeInsets!
    
    @IBOutlet weak var autocompleteSearchBar: AutocompleteSearchBar!{
        didSet{
            autocompleteSearchBar.source = "buyer"
        }
    }
    @IBOutlet weak var filterBar: UIView!
    @IBOutlet weak var nearLabel: UILabel!
  
//    @IBOutlet weak var searchBar: UISearchBar!{
//        didSet{
//            searchBar.delegate = self
//            searchBar.barTintColor = UIColor.whiteColor()
//            
//            //make the border bigger and gray
//            for object in searchBar.subviews.first!.subviews {
//                if object.isKindOfClass(UITextField) {
//                    if let object = object as? UITextField {
//                        object.layer.borderColor = UIColor.kitGrey().CGColor
//                        object.layer.borderWidth = 3
//                        object.layer.cornerRadius = 3
//                    }
//                }
//            }
//        }
//    }
    @IBOutlet weak var resetLocationFilterButton: UIButton!
    @IBAction func resetLocationFilterButtonPressed(sender: AnyObject) {
        filterLocation = nil
//        serverCall()
        filterCall()
    }
    
    @IBOutlet weak var filteredLocationLabel: UILabel!{
        didSet{
            filteredLocationLabel.textColor = UIColor.kitBlack189()
            filteredLocationLabel.layer.borderColor = UIColor.kitGreen().CGColor
            filteredLocationLabel.layer.borderWidth = 1
            filteredLocationLabel.layer.cornerRadius = 5
            filteredLocationLabel.clipsToBounds = true
        }
    }
    
    
    @IBOutlet weak var resetCategoryFilterButton: UIButton!
    @IBAction func resetCategoryFilterPressed(sender: AnyObject) {
        filterCategory = nil
//        serverCall()
        filterCall()
    }
    @IBOutlet weak var filteredCategoryLabel: UILabel!{
        didSet{
            filteredCategoryLabel.backgroundColor = UIColor.kitBlue()
            filteredCategoryLabel.layer.cornerRadius = 5
            filteredCategoryLabel.clipsToBounds = true
        }
    }
    @IBOutlet weak var filterLocationLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var filterCategoryLabelWidthConstraint: NSLayoutConstraint!
    var filterCategory:String?{
        didSet{
            if filterCategory == nil {
                filteredCategoryLabel.hidden = true
                resetCategoryFilterButton.hidden = true
            }else{
                filteredCategoryLabel.hidden = false
                resetCategoryFilterButton.hidden = false
                
                let locationWidth = widthForString(filterCategory!, font: filteredCategoryLabel.font, height: CGFloat.max)
                filterCategoryLabelWidthConstraint.constant = locationWidth + 10
                filterBar.layoutIfNeeded()

                filteredCategoryLabel.text = filterCategory
                filterBar.hidden = false
                collectionView.contentInset = UIEdgeInsetsMake(50, oldInset.left, oldInset.bottom, oldInset.right)
                collectionView.setContentOffset(CGPointMake(0,-50), animated: false)
            }
            hideFilterBarIfNeeded()
        }
    }
    
    func widthForString(string: String, font: UIFont, height: CGFloat) -> CGFloat {
        let rect = NSString(string: string).boundingRectWithSize(CGSize(width: CGFloat(MAXFLOAT), height: height), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return ceil(rect.width)
    }

    var filterLocation:Location?{
        didSet{
            if filterLocation == nil {
                filteredLocationLabel.hidden = true
                resetLocationFilterButton.hidden = true
                nearLabel.hidden = true
            }else{
                filteredLocationLabel.hidden = false
                resetLocationFilterButton.hidden = false
                nearLabel.hidden = false
                
                let locationString = "\(filterLocation!.city), \(filterLocation!.state)"
                
                let locationWidth = widthForString(locationString, font: filteredLocationLabel.font, height: CGFloat.max)
                filterLocationLabelWidthConstraint.constant = locationWidth + 10
                filterBar.layoutIfNeeded()

                filteredLocationLabel.text = locationString
                filterBar.hidden = false
                collectionView.contentInset = UIEdgeInsetsMake(50, oldInset.left, oldInset.bottom, oldInset.right)
                collectionView.setContentOffset(CGPointMake(0,-50), animated: false)
            }
            hideFilterBarIfNeeded()
        }
    }
    
    var allOrRecommendedSwitch: DGRunkeeperSwitch!
    
    var items = [Item]()
    var allItems = [Item]()
    var cachedAllItems = [Item]()
    var cachedRecomendedItems = [Item]()
    
    var lastAllItemsCallDate: NSDate?
    var lastRecomendedCallDate: NSDate?

    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            oldInset = collectionView.contentInset
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView!.backgroundColor = UIColor.kitBackground()
        collectionView!.contentInset = UIEdgeInsets(top: Constant.CollectionViewTopPadding, left: 0, bottom: 10, right: 0)
        collectionView.registerNib(UINib(nibName: Constant.ItemCell, bundle: nil), forCellWithReuseIdentifier: Constant.ItemCell)
        collectionView.delegate = self
        collectionView.dataSource = self
        
      if let layout = collectionView?.collectionViewLayout as? PinterestLayout {
            layout.itemInsets = UIEdgeInsets(top: Constant.CollectionViewTopPadding, left: 5, bottom: 10, right: 5)
            layout.delegate = self
        }
        
        allOrRecommendedSwitch = getDGRunkeeperSwitch("ALL", rightTitle: "RECOMMENDED")
        allOrRecommendedSwitch.addTarget(self, action: #selector(BrowseViewController.onChange), forControlEvents: .ValueChanged)
        navigationItem.titleView = allOrRecommendedSwitch

        autocompleteSearchBar?.delegate = self
        autocompleteSearchBar?.searchView = self.view

        serverCall()
    }
    
    func onChange() {
        serverCall()
    }
    
    func isAllTab() -> Bool {
        return allOrRecommendedSwitch.selectedIndex == 0
    }
    
    func isRecommendedTab() -> Bool {
        return allOrRecommendedSwitch.selectedIndex == 1
    }
    
    func serverCall(){
        
        let params:[String:AnyObject] = [
            "network_distance": "6" //this is required right now because there's no data in the DB but if you pass network_distance=6 it finds a sample item
        ]
        
        let completionBlock: CompletionBlock = { [weak self] response, error in
            guard let strongSelf = self else { return }
            strongSelf.hideLoader()
            
            if error == nil {
                print(response)
                guard let itemListings = response as? [[String:AnyObject]] else {
                    print("Could not parse listings filter call into array")
                    return
                }
                
                strongSelf.allItems = itemListings.map { Item(json: $0) }
                
                if strongSelf.isAllTab() {
                    strongSelf.cachedAllItems = strongSelf.allItems
                    strongSelf.lastAllItemsCallDate = NSDate()
                } else {
                    strongSelf.cachedRecomendedItems = strongSelf.allItems
                    strongSelf.lastRecomendedCallDate = NSDate()
                }
                
                strongSelf.filterCall()
            } else {
                strongSelf.handlerError(error)
            }
        }

        if isAllTab() {

            if !showReloadAllTab() {
                allItems = cachedAllItems
                filterCall()
            } else {
                showLoader()
                Connection(configuration: nil).listingsFilterCall(params, completionBlock: completionBlock)
            }
            
        } else {
            
            if !showReloadRecomendedTab() {
                allItems = cachedRecomendedItems
                filterCall()
            } else {
                showLoader()
                Connection(configuration: nil).listingsRecommendedCall(params, completionBlock: completionBlock)
            }
        }
    }
    
    func showReloadAllTab() -> Bool {
        guard let lastDate = lastAllItemsCallDate else { return true }
        let now = NSDate()
        let minsBetween = now.timeIntervalSinceDate(lastDate) / 60
        return minsBetween > 5
    }
    
    func showReloadRecomendedTab() -> Bool {
        guard let lastDate = lastRecomendedCallDate else { return true }
        let now = NSDate()
        let minsBetween = now.timeIntervalSinceDate(lastDate) / 60
        return minsBetween > 5
    }
    
    func filterCall(){
        items = []
        reloadCollectionView()
      
        if filterCategory != nil || filterLocation != nil {
            items = allItems.filter { (item) -> Bool in
                var includeItem = false
                //if both are active, we need an AND query, so both must match
                if filterCategory != nil && filterLocation != nil {
                    if item.category == filterCategory! && item.location.city == filterLocation!.city && item.location.state == filterLocation!.state {
                        includeItem = true
                    }
                }else{
                    //do filtering on one or the other (location or category)
                    if filterCategory != nil {
                        if item.category == filterCategory! {
                            includeItem = true
                        }
                    }
                    if filterLocation != nil {
                        if item.location.city == filterLocation!.city && item.location.state == filterLocation!.state {
                            includeItem = true
                        }
                    }

                }
                return includeItem
            }
        }else{
            //return all items, no filters
            items = allItems
        }
        reloadCollectionView()
    }
    
    func reloadCollectionView(){
        if let layout = collectionView?.collectionViewLayout as? PinterestLayout {
            layout.emptyLayoutCache()
        }
        collectionView.reloadData()
        collectionView.contentOffset = CGPoint(x: -collectionView.contentInset.left, y: -collectionView.contentInset.top)
    }
    
    func resetFilters(){
        filterCategory = nil
        filterLocation = nil
    }
    
    func hideFilterBarIfNeeded(){
        if filterLocation == nil && filterCategory == nil {
            filterBar.hidden = true
            collectionView.contentInset = oldInset
            collectionView.setContentOffset(CGPointMake(0,0), animated: false)
        }
    }
  
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constant.ListingDetailsSegueIdentifier {
            let item = sender as! Item
            let vc = segue.destinationViewController as! ListingDetailsViewController
            vc.title = item.title
            vc.navigationItem.title = item.title
          
            vc.item = item
        }
    }

    func searchByKeyword(){
        showLoader()
        let params = [
            "query": autocompleteSearchBar.textField()?.text ?? ""
        ]
        Connection(configuration: nil).listingsSearchCall(params) { [weak self] response, error in
            self?.hideLoader()
            if error == nil {
                //convert response to array
                guard let itemListings = response as? [[String:AnyObject]] else {
                    print("Could not parse recommended listings call into array")
                    return
                }
                self?.items = itemListings.map { Item(json: $0) }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self?.reloadCollectionView()
                    self?.autocompleteSearchBar.textField()?.resignFirstResponder()
//                    searchBar.resignFirstResponder()
                })
            } else {
                self?.handlerError(error)
            }
        }
    }
}

extension BrowseViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constant.ItemCell, forIndexPath: indexPath) as! ItemCell
        cell.item = items[indexPath.row]
        cell.delegate = self
        return cell
    }
  
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row >= items.count {
            return
        }
    
        performSegueWithIdentifier(Constant.ListingDetailsSegueIdentifier, sender: items[indexPath.row])
    }
    
}

extension BrowseViewController : PinterestLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {
        
        let item = items[indexPath.item]
        let font = UIFont(name: "Lato", size: 13)!
        let commentHeight = min(Constant.MaxLabelHeight, item.heightForTitle(font, width: width - 30))
        let height = commentHeight + 229
        return height
    }
}

extension BrowseViewController: UITextFieldDelegate{
    // called when keyboard search button pressed
    func searchBarSearchButtonClicked(searchBar: UISearchBar){

    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar){
        searchBar.resignFirstResponder()
        autocompleteSearchBar.textField()?.text = ""
        serverCall()
    }

    func searchBarTextDidBeginEditing(searchBar: UISearchBar){
//        searchBar.showsCancelButton = true
        filtersEnabled = false
        resetFilters()
    }
    

    func searchBarTextDidEndEditing(searchBar: UISearchBar){
//        searchBar.showsCancelButton = false
        filtersEnabled = true
    }
}

extension BrowseViewController: ItemListingProtocol{
    func didTapCategory(category: String){
        print("category \(category) was tapped")
        if filtersEnabled == false{
            return
        }
        filterCategory = category
        if !isAllTab() {
            //switch the user back to the All segment since Recommended doesn't support search
            //this should trigger a serverCall() because of the listener on the change of the segmented control
            allOrRecommendedSwitch.setSelectedIndex(0, animated: true)
        }else{
//            serverCall()
            filterCall()
        }
    }
    
    func didTapLocation(location: Location){
        print("location \(location) was tapped")
        if filtersEnabled == false{
            return
        }
        filterLocation = location
        if !isAllTab() {
            //switch the user back to the All segment since Recommended doesn't support search
            //this should trigger a serverCall() because of the listener on the change of the segmented control
            allOrRecommendedSwitch.setSelectedIndex(0, animated: true)
        }else{
//            serverCall()
            filterCall()
        }
    }
}

extension BrowseViewController: AutocompleteSearchBarDelegate{
    func searchTextSelected(searchBar: AutocompleteSearchBar, term: String){
        print("selected \(term)")
        searchByKeyword()
    }

    func searchTextBeganEditing() {
        filtersEnabled = false
        resetFilters()
    }

    func searchTextEndedEditing() {
        filtersEnabled = true
    }

    func searchTextCancelTapped() {
        autocompleteSearchBar.textField()?.resignFirstResponder()
        serverCall()
    }

}
