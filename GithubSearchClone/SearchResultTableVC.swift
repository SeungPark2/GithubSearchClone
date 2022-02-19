//
//  SearchResultTableVC.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/18.
//

import UIKit

protocol resultDelegate: AnyObject {
    
    func didSelectSearchWord()
}

class SearchResultTableVC: UITableViewController {
 
    weak var resultDeleagte: resultDelegate?
    var repositories = [Repository]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("ds")
    }
}
