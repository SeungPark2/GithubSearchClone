//
//  UIApplication+Extension.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/20.
//

import UIKit

extension UIApplication {
    
    class func topViewController(base: UIViewController? = UIApplication.shared.windows.last?.rootViewController) -> UIViewController? {
        
            if let nav = base as? UINavigationController {
                
                return topViewController(base: nav.visibleViewController)
            }
        
            if let tab = base as? UITabBarController {
                
                if let selected = tab.selectedViewController {
                    
                    return topViewController(base: selected)
                }
            }
        
            if let presented = base?.presentedViewController {
                
                return topViewController(base: presented)
            }
        
            return base
        }
}
