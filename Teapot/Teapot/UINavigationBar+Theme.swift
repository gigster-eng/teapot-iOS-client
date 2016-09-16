import UIKit

extension UINavigationBar {
    func applyTheme(navigationTheme: NavigationTheme) {
        barTintColor = navigationTheme.barTintColor
        tintColor = navigationTheme.tintColor
        titleTextAttributes = navigationTheme.titleTextAttributes
    }
}
