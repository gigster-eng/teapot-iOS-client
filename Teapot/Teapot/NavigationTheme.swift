    import UIKit

enum NavigationTheme {
    case Normal
    case Small
    
    var statusBarStyle: UIStatusBarStyle {
        switch self {
        case .Normal: return .LightContent
        case .Small: return .LightContent
        }
    }
    
    var barTintColor: UIColor? {
        switch self {
        case .Normal: return UIColor.kitGreen()
        case .Small: return UIColor.kitGreen()
        }
    }
    
    var titleTextAttributes: [String: NSObject]? {
        switch self {
        case .Normal: return [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont.kitBoldSystemFontOfSize(17)!
          ]
        case .Small: return [
          NSForegroundColorAttributeName: UIColor.whiteColor(),
          NSFontAttributeName: UIFont.kitBoldSystemFontOfSize(10)!
          ]
        }
    }
    
    var tintColor: UIColor {
        switch self {
        case .Normal: return UIColor.whiteColor()
        case .Small: return UIColor.whiteColor()
        }
    }
}