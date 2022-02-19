//
//  ProfileVC.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/19.
//

import UIKit

class ProfileVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBOutlet private weak var loginBarButton: UIBarButtonItem?
    
    @IBOutlet private weak var loginGuideLabel: UILabel?
    @IBOutlet private weak var loginButton: UIButton?
    
    @IBOutlet private weak var userInfoView: UIView?
    @IBOutlet private weak var userImageView: UIImageView?
    @IBOutlet private weak var userNameLabel: UILabel?
    
    @IBOutlet private var userStarTableView: UITableView!
}
