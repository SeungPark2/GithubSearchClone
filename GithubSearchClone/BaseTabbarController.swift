//
//  BaseTabbarController.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/03/10.
//

import UIKit

class BaseTabbarController: UITabBarController {
    
    var searchNaviController: UINavigationController?
    var profileNaviController: UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setTabbar()
        self.addSearchTab()
        self.addProfileTab()
        
        self.setViewControllers([self.searchNaviController ?? UINavigationController(),
                                 self.profileNaviController ?? UINavigationController()],
                                animated: true)
    }
    
    func setTabbar() {
        
        self.tabBar.backgroundColor = #colorLiteral(red: 0.2509803922, green: 0.2509803922, blue: 0.2509803922, alpha: 1)
        self.tabBar.tintColor = .white
        self.tabBar.unselectedItemTintColor = #colorLiteral(red: 0.137254902, green: 0.1647058824, blue: 0.3921568627, alpha: 1)
    }
    
    func addSearchTab() {
        
        self.searchNaviController = UINavigationController(rootViewController: RepositoryListVC())
        
        self.searchNaviController?.tabBarItem.title = "검색"
        self.searchNaviController?.tabBarItem.image = UIImage(systemName: "magnifyingglass")
    }
    
    func addProfileTab() {
        
        self.profileNaviController = UINavigationController(rootViewController: ProfileVC())
        
        self.profileNaviController?.tabBarItem.title = "프로필"
        self.profileNaviController?.tabBarItem.image = UIImage(systemName: "person")
    }
}
