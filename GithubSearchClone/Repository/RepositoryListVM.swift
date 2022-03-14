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
    
    func reset()
    func search(with searchWord: String)
    
    func typingWords(with searchWord: String)
    
    func requestFullName()
    func requestRepo()
    
    func refreshRepo()
    
    func requestChangeStar(with index: Int)
}

class RepositoryListVM: RepositoryListVMProtocol {
    
    private var service: RepositoryListServiceProtocol
    
    init(repositoryListService: RepositoryListServiceProtocol) {
        
        self.service = repositoryListService
    }
    
    // MARK: -- Public Properties
    
    var isLoaded = BehaviorRelay<Bool>(value: true)
    var errMsg = BehaviorRelay<String>(value: "")
            
    var repositories = BehaviorRelay<[Repository]>(value: [])
    var fullNames = BehaviorRelay<[FullName]>(value: [])
    
    // MARK: -- Public Method
    
    func reset() {
        
        self.repositories.accept([])
        self.fullNames.accept([])
        self.searchWord = ""
    }
    
    func typingWords(with searchWord: String) {
        
        self.searchWord = searchWord
        
        self.requestFullName()
    }
     
    func search(with searchWord: String) {
        
        self.searchWord = searchWord
        
        self.requestRepo()
    }
    
    func refreshRepo() {
        
        if self.searchWord == "" {
            
            self.isLoaded.accept(true)
            return
        }
        
        self.requestRepo()
    }
    
    func requestFullName() {
        
        guard self.service.fullNameNextPage != nil,
              self.isLoaded.value else {
            
            return
        }
        
        self.isLoaded.accept(false)
        
        self.service.requestFullName(with: self.searchWord)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] fullNameList in
                    
                    self?.fullNames.accept((self?.fullNames.value ?? []) + fullNameList)
                    
                    self?.isLoaded.accept(true)                    
                },
                onError: { [weak self] in
                    
                    self?.isLoaded.accept(true)
                    
                    self?.errMsg.accept(
                        ($0 as? APIError)?.description ?? ""
                    )
                }
            )
            .disposed(by: self.disposeBag)
    }
    
    func requestRepo() {
        
        guard self.service.repoNextPage != nil,
              self.isLoaded.value,
              self.searchWord != "" else {
            
            return
        }
        
        self.isLoaded.accept(false)
        
        self.service.requestRepo(with: self.searchWord)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] repos in
                    
//                    for repo in repos {
//
//                        if UserInfo.shared.starRepos.filter({
//                            $0.id == repo.id }).isEmpty {
//
//                            repo.isAddedStart = true
//                        }
//                    }
                    
                    self?.repositories.accept(repos)
                    self?.isLoaded.accept(true)
            },
                onError: { [weak self] in
                
                    self?.errMsg.accept(
                        (($0 as? APIError)?.description) ?? ""
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
        
        self.service.requestChangeStar(with: selectedRepo)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] _ in
                    
                    selectedRepo.isAddedStart = !isAdded
                    
                    isAdded ? UserInfo.shared.removeStarRepo(selectedRepo) :
                              UserInfo.shared.addStarRepo(selectedRepo)
                    
                    self?.isLoaded.accept(true)
                },
                onError: { [weak self] in
                    
                    self?.isLoaded.accept(true)
                    
                    self?.errMsg.accept(
                        ($0 as? APIError)?.description ?? ""
                    )
                }
            )
            .disposed(by: self.disposeBag)
    }
    
    // MARK: -- Private Method
    
    // MARK: -- Private Properties
    
    private var searchWord: String = ""    
    
    private let disposeBag = DisposeBag()
}
