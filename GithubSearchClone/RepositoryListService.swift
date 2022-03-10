//
//  RepositoryListService.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/03/08.
//

import Foundation

protocol RepositoryListServiceProtocol {
    
    func requestFullName(with searchWord: String)
    func requestRepo(with searchWord: String)
}

class RepositoryListService: RepositoryListServiceProtocol {
    
    func requestFullName(with searchWord: String) {
        
    }
    
    func requestRepo(with searchWord: String) {
        
    }
    
    private var repoNextPage: Int? = 1
    private var fullNameNextPage: Int? = 1
    private var isLoadingFullNameNextPage: Bool = false
}
