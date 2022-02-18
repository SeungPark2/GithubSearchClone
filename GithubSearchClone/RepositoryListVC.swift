//
//  RepositoryListVC.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/18.
//

import UIKit

class RepositoryListVC: UIViewController {

    // MARK: -- Public Properties
    
    // MARK: -- Public Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        initSearchController()
    }
    
    // MARK: -- Private Method
    
    private func initSearchController() {
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "저장소명 또는 소유자명 검색"
        searchController.searchBar.setValue("취소",
                                            forKey: "cancelButtonText")
        searchController.searchBar.tintColor = .white
        self.navigationItem.searchController = searchController
        
        self.navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    // MARK: -- Private Properties
    
    // MARK: -- IBOutlet
    
    @IBOutlet private weak var loginButton: UIBarButtonItem?
    
    @IBOutlet private weak var repositoryTableView: UITableView?
}

