//
//  UITabbarController+Extension.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/25.
//

import UIKit

extension UITabBarController {
    
    /// Extends the size of the `UITabBarController` view frame, pushing the tab bar controller off screen.
    /// - Parameters:
    ///   - hidden: Hide or Show the `UITabBar`
    ///   - animated: Animate the change
    ///
    func setTabBarHidden(_ hidden: Bool, animated: Bool) {
        
        guard let vc = selectedViewController else { return }
        guard self.tabBarHidden != hidden else { return }
        
        let frame = self.tabBar.frame
        let height = frame.size.height
        let offsetY = hidden ? height : -height

        UIViewPropertyAnimator(duration: animated ? 0.3 : 0,
                               curve: .easeOut) {
            
            self.tabBar.frame = self.tabBar.frame.offsetBy(dx: 0, dy: offsetY)
            self.selectedViewController?.view.frame = CGRect(
                x: 0,
                y: 0,
                width: vc.view.frame.width,
                height: vc.view.frame.height + offsetY
            )
            
            self.view.setNeedsDisplay()
            self.view.layoutIfNeeded()
        }
        .startAnimation()
    }
    
    /// Is the tab bar currently off the screen.
    private var tabBarHidden: Bool {
        
        tabBar.frame.origin.y >= UIScreen.main.bounds.height
    }
}

