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
    
    var isHiddenEmptyText: BehaviorRelay<Bool> { get }
    var isHiddenFullNames: BehaviorRelay<Bool> { get }
    
    func reset()
    func search(with fullName: String)
    
    func typingWords(with searchWord: String)
    
    func requestFullName()
    func requestRepo()
    
    func refreshRepo()
    
    func requestChangeStar(with index: Int)
}

class RepositoryListVM: RepositoryListVMProtocol {
    
    // MARK: -- Public Properties
    
    var isLoaded = BehaviorRelay<Bool>(value: true)
    var errMsg = BehaviorRelay<String>(value: "")
            
    var repositories = BehaviorRelay<[Repository]>(value: [])
    var fullNames = BehaviorRelay<[FullName]>(value: [])
    
    var isHiddenEmptyText = BehaviorRelay<Bool>(value: true)
    var isHiddenFullNames = BehaviorRelay<Bool>(value: true)
    
    // MARK: -- Public Method
    
    func reset() {
        
        self.isHiddenFullNames.accept(true)
        self.repositories.accept([])
        self.fullNames.accept([])
        self.fullNameNextPage = 1
        self.repoNextPage = 1
        self.searchWord = ""
        self.isHiddenEmptyText.accept(true)
    }
    
    func typingWords(with searchWord: String) {
        
        self.searchWord = searchWord
        self.fullNameNextPage = 1
        
        self.requestFullName()
        self.isHiddenEmptyText.accept(true)
    }
     
    func search(with searchWord: String) {
        
        self.searchWord = searchWord
        self.repoNextPage = 1
        self.isHiddenFullNames.accept(true)
        self.isHiddenEmptyText.accept(true)
        
        self.requestRepo()
    }
    
    func refreshRepo() {
        
        if self.searchWord == "" {
            
            self.isLoaded.accept(true)
            return
        }
        
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
                    "per_page": 20,
                    "page": nextPage]
        )
            .map { $0.data }
            .decode(type: RepositoryFullNames.self, decoder: JSONDecoder())
            .subscribe(
                onNext: { [weak self] repository in
                
                    var fullNames = repository.fullNames
                    
                    if nextPage > 1 {
                        
                        fullNames = (self?.fullNames.value ?? []) + repository.fullNames
                    }
                    
                    self?.fullNames.accept(fullNames)
                    
                    if !(self?.isHiddenFullNames.value ?? true) {
                        
                        self?.isHiddenEmptyText.accept(!fullNames.isEmpty)
                    }
                    
                    if (repository.totalCount ?? 0) - (30 * nextPage) > 0 {
                        
                        self?.fullNameNextPage = nextPage + 1
                    }
                    else {
                        
                        self?.fullNameNextPage = nil
                    }
                                                                                
                    self?.isLoadingFullNameNextPage = false
            },
                onError: { [weak self] _ in                                        
                    
                    self?.isLoadingFullNameNextPage = false
                })
            .disposed(by: self.disposeBag)
    }
    
    func requestRepo() {
        
        guard let nextPage = self.repoNextPage,
              self.isLoaded.value,
              self.searchWord != "" else {
            
            return
        }
        
        self.isLoaded.accept(false)
        
        Network.shared.requestGet(
            with: Root.search + EndPoint.repositories,
            query: ["q": self.searchWord,
                    "per_page": 10,
                    "page": nextPage]
        )
            .map { $0.data }
            .decode(type: Repositories.self, decoder: JSONDecoder())
            .subscribe(
                onNext: { [weak self] repo in
                
                    var repositories = repo.items
                    
                    let repoCount: Int = repositories.count
                    for i in 0..<repoCount {
                        
                        if !UserInfo.shared.starRepos.filter({
                                $0.id == repositories[i].id }).isEmpty {
                            
                            repositories[i].isAddedStart = true
                        }
                    }
                    
                    if nextPage > 1 {

                        repositories = (self?.repositories.value ?? []) + repo.items
                    }

                    self?.repositories.accept(repositories)
                    self?.isHiddenEmptyText.accept(!repositories.isEmpty)
                    
                    if (repo.totalCount ?? 0) - (10 * nextPage) > 0 {
                        
                        self?.repoNextPage = nextPage + 1
                    }
                    else {
                        
                        self?.repoNextPage = nil
                    }

                    self?.isLoaded.accept(true)
            },
                onError: { [weak self] in
                
                    self?.errMsg.accept(
                        (($0 as? NetworkError)?.description) ?? ""
                    )
                    
                    self?.isLoaded.accept(true)
            })
            .disposed(by: self.disposeBag)
    }
    
    func requestChangeStar(with index: Int) {
        
        if UserInfo.shared.apiToken == "" {
            
            self.errMsg.accept(ErrorMessage.requireLogin)
            return
        }
        
        guard let selectedRepo = self.repositories.value[safe: index],
              let isAdded = self.repositories.value[safe: index]?.isAddedStart else {
            
            return
        }
        
        self.isLoaded.accept(false)
        
        Network.shared.requestBody(with: Root.user +
                                         EndPoint.startList +
                                         "/\(selectedRepo.owner.name)/" +
                                         "\(selectedRepo.name)",
                                   params: [:],
                                   httpMethod: isAdded ? .delete : .put)
            .subscribe(
                onNext: { [weak self] _ in
                    
                    var copyRepos = self?.repositories.value
                    
                    copyRepos?[index].isAddedStart = !isAdded
                    
                    self?.repositories.accept(copyRepos ?? [])
                    self?.isLoaded.accept(true)
                    
                    isAdded ? UserInfo.shared.removeStarRepo(selectedRepo) :
                              UserInfo.shared.addStarRepo(selectedRepo)
            },
                onError: { [weak self] _ in
                    
                    self?.errMsg.accept(isAdded ? ErrorMessage.failedAddStar :
                                                  ErrorMessage.failedRemoveStar)
                    self?.isLoaded.accept(true)
            })
            .disposed(by: self.disposeBag)
    }
    
    // MARK: -- Private Method
    
    // MARK: -- Private Properties
    
    private var searchWord: String = ""    
    
    private let disposeBag = DisposeBag()
}
