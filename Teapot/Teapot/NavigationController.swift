import UIKit

class NavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.applyTheme(.Normal)
    }
    
    var statusBarStyle: UIStatusBarStyle = .LightContent {
        didSet { setNeedsStatusBarAppearanceUpdate() }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return statusBarStyle
    }
}
