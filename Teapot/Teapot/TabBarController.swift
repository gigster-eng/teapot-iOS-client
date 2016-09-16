import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    var shouldPresentInterests = false
    var selectedBackground: UIView!
    
    let unSelectedImageNames = [
        UIImage(assetIdentifier: .menu_browse),
        UIImage(assetIdentifier: .menu_sell),
        UIImage(assetIdentifier: .menu_friends),
        UIImage(assetIdentifier: .menu_messages),
        UIImage(assetIdentifier: .menu_profile),
    ]
    
    let selectedImageNames = [
        UIImage(assetIdentifier: .menu_browse_active),
        UIImage(assetIdentifier: .menu_sell_active),
        UIImage(assetIdentifier: .menu_friends_active),
        UIImage(assetIdentifier: .menu_messages_active),
        UIImage(assetIdentifier: .menu_profile_active),
    ]
    
    let titles = [
        "Browse",
        "Sell",
        "Friends",
        "Messages",
        "Profile"
    ]
    
    var width: CGFloat {
        return view.frame.width / 5
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
     
        let frame = CGRectMake(0, 0, tabBar.frame.width / 5, tabBar.frame.height)
        let selectedBackground = UIView(frame: frame)
        selectedBackground.backgroundColor = UIColor.kitGreen()
        self.selectedBackground = selectedBackground
        tabBar.insertSubview(selectedBackground, atIndex: 0)
    }
    
    func selectIndex(index: Int) {
        selectedBackground.center = CGPointMake(CGFloat(index) * width + width / 2, selectedBackground.center.y)
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        selectIndex(selectedIndex)
    }
  
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if selectedIndex == 1 && viewControllers?.indexOf(viewController) == 1 && User.currentUser?.listings.count == 0 {
            return false
        }
      
        return true
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func updateUI() {
        let tabItems = tabBar.items!
        let offSet: CGFloat = 5
        delegate = self
        
        for index in 0...4 {
            let tabItem: UITabBarItem = tabItems[index]
            let selectedImageName = selectedImageNames[index]
            let unSelectedImageName = unSelectedImageNames[index]
            
            tabItem.title = titles[index]
            tabItem.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.whiteColor()], forState: .Selected)
            
            tabItem.imageInsets = UIEdgeInsetsMake(offSet, 0, -offSet, 0)
            tabItem.image = unSelectedImageName.imageWithRenderingMode(.AlwaysOriginal)
            tabItem.selectedImage = selectedImageName.imageWithRenderingMode(.AlwaysOriginal)
        }
    }
}
