//
//  RepositoryReactor.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/18.
//

import RxSwift
import RxCocoa

protocol RepositoryListVMProtocol {
    
    var isLoaded: BehaviorRelay<Bool> { get }
    var errMsg: BehaviorRelay<String> { get }
    
    var repositories: BehaviorRelay<[Repository]> { get }
    var fullNames: BehaviorRelay<[FullName]> { get }
    
    var isHideFullNames: BehaviorRelay<Bool> { get }
    
    func requestLogin()
    func typingWords(with searchWord: String)
    func didTapFullName(with fullName: String)
    func requestFullName()
    func requestRepo()
}

class RepositoryListVM: RepositoryListVMProtocol {
    
    var isLoaded = BehaviorRelay<Bool>(value: true)
    var errMsg = BehaviorRelay<String>(value: "")
    
    var repositories = BehaviorRelay<[Repository]>(value: [])
    var fullNames = BehaviorRelay<[FullName]>(value: [])
    
    var isHideFullNames = BehaviorRelay<Bool>(value: true)
    
    func requestLogin() {
        
        
    }
    
    func typingWords(with searchWord: String) {
        
        self.searchWord = searchWord
        self.fullNameNextPage = 1
        
        self.requestFullName()
    }
    
    func didTapFullName(with fullName: String) {
        
        self.searchWord = fullName
        self.repoNextPage = 1
        
        self.requestRepo()
    }
    
    func requestFullName() {
        
        guard let nextPage = self.fullNameNextPage,
              !self.isLoadingFullNameNextPage else {
            
            return
        }
        
        self.isLoadingFullNameNextPage = true
        
        Network.shared.requestGet(
            with: Root.search + EndPoint.repositories,
            query: ["q": self.searchWord,
                    "per_page": 10,
                    "page": nextPage]
        )
            .decode(type: RepositoryFullNames.self, decoder: JSONDecoder())
            .subscribe(
                onNext: { [weak self] repository in
                
                    var fullNames = repository.fullNames
                    
                    if nextPage > 1 {
                        
                        fullNames = (self?.fullNames.value ?? []) + repository.fullNames
                    }
                    
                    self?.fullNames.accept(fullNames)
                    
                    if (repository.totalCount ?? 0) - (30 * nextPage) > 0 {
                        
                        self?.fullNameNextPage = nextPage + 1
                    }
                    else {
                        
                        self?.fullNameNextPage = nil
                    }
                    
                    self?.isLoadingFullNameNextPage = false
            },
                onError: { [weak self] in
                    
                    self?.errMsg.accept(
                        (($0 as? Network.NetworkError)?.description) ?? ""
                    )
                    self?.isLoadingFullNameNextPage = false
                })
            .disposed(by: self.disposeBag)
    }
    
    func requestRepo() {
        
        guard let nextPage = self.repoNextPage,
              !self.isLoadingRepoNextPage,
              self.searchWord != "" else {
            
            return
        }
        
        self.isLoaded.accept(false)
        self.isLoadingRepoNextPage = true
        
        Network.shared.requestGet(
            with: Root.search + EndPoint.repositories,
            query: ["q": self.searchWord,
                    "per_page": 10,
                    "page": nextPage]
        )
            .decode(type: Repositories.self, decoder: JSONDecoder())
            .subscribe(
                onNext: { [weak self] repo in
                
                    var repositories = repo.items
                    
                    if nextPage > 1 {
                        
                        repositories = (self?.repositories.value ?? []) + repo.items
                    }
                    
                    self?.repositories.accept(repositories)
                    
                    self?.isLoaded.accept(true)
                    
                    if (repo.totalCount ?? 0) - (10 * nextPage) > 0 {
                        
                        self?.repoNextPage = nextPage + 1
                    }
                    else {
                        
                        self?.repoNextPage = nil
                    }
                    
                    self?.isLoadingRepoNextPage = false
            },
                onError: { [weak self] in
                
                    self?.errMsg.accept(
                        (($0 as? Network.NetworkError)?.description) ?? ""
                    )
                    self?.isLoaded.accept(true)
                    self?.isLoadingRepoNextPage = false
            })
            .disposed(by: self.disposeBag)
    }
    
    private var searchWord: String = ""
    private var repoNextPage: Int? = 1
    private var fullNameNextPage: Int? = 1
    private var isLoadingRepoNextPage: Bool = false
    private var isLoadingFullNameNextPage: Bool = false
    
    private let disposeBag = DisposeBag()
}
