//
//  ProfileVM.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/19.
//

import RxSwift
import RxCocoa

protocol ProfileVMProtocol {
    
    var isLoaded: BehaviorRelay<Bool> { get }
    var errMsg: BehaviorRelay<String> { get }
    
    var user: BehaviorRelay<User?> { get }
    
    var starRepos: BehaviorRelay<[Repository]?> { get }
    
    func requestUserInfo()
    func requestStarRepo(with viewWillAppear: Bool)
    func requestChangeStar(at index: Int)
}

class ProfileVM: ProfileVMProtocol {
    
    // MARK: -- Public Properties
    
    var isLoaded = BehaviorRelay<Bool>(value: true)
    var errMsg = BehaviorRelay<String>(value: "")
    
    var user = BehaviorRelay<User?>(value: nil)    
    
    var starRepos = BehaviorRelay<[Repository]?>(value: nil)
    
    // MARK: -- Public Method
    
    func requestUserInfo() {
        
        if UserInfo.shared.apiToken != "", user.value == nil {
            
            Network.shared.requestGet(with: Root.user,
                                      query: nil)
                .decode(type: User.self, decoder: JSONDecoder())
                .subscribe(
                    onNext: { [weak self] userInfo in
                        
                        self?.user.accept(userInfo)
                    },
                    onError: { [weak self] in
                        
                        self?.errMsg.accept(
                            (($0 as? Network.NetworkError)?.description) ?? ""
                        )
                    })
                .disposed(by: self.disposeBag)
        }
    }
    
    func requestStarRepo(with viewWillAppear: Bool) {
        
        guard UserInfo.shared.apiToken != "",
              let nextPage = self.repoNextPage,
              !self.isLoadingRepoNextPage else {
            
            return
        }
        
        self.isLoaded.accept(false)
        self.isLoadingRepoNextPage = true
        
        Network.shared.requestGet(with: Root.user + EndPoint.startList,
                                  query: nil)
            .decode(type: [Repository].self, decoder: JSONDecoder())
            .subscribe(
                onNext: { [weak self] repo in
                    
                    var repositories = repo
                    
                    let repoCount: Int = repositories.count
                    for i in 0..<repoCount {
                        
                        repositories[i].isAddedStart = true
                    }
                    
                    if nextPage > 1 {

                        repositories = (self?.starRepos.value ?? []) + repo
                    }

                    self?.starRepos.accept(repositories)

                    self?.isLoaded.accept(true)

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
    
    func requestChangeStar(at index: Int) {
        
        guard let repoName = self.starRepos.value?[safe: index]?.name,
              let ownerName = self.starRepos.value?[safe: index]?.owner.name,
              let isAdded = self.starRepos.value?[safe: index]?.isAddedStart else {
            
            return
        }
        
        self.isLoaded.accept(false)
        
        Network.shared.requestBody(with: Root.user +
                                         EndPoint.startList +
                                         "/\(ownerName)/\(repoName)",
                                   params: [:],
                                   httpMethod: isAdded ? .delete : .put)
            .subscribe(
                onNext: { [weak self] _ in
                    
                    var copyRepos = self?.starRepos.value
                    
                    copyRepos?[index].isAddedStart = !isAdded
                    
                    self?.starRepos.accept(copyRepos ?? [])
                    self?.isLoaded.accept(true)
            },
                onError: { [weak self] _ in
                    
                    self?.errMsg.accept(ErrorMessage.failedRemoveStar)
                    self?.isLoaded.accept(true)
            })
            .disposed(by: self.disposeBag)
    }
    
    // MARK: -- Private Method
    
    // MARK: -- Private Properties
    
    private var repoNextPage: Int? = 1
    private var isLoadingRepoNextPage: Bool = false
    private let disposeBag = DisposeBag()
}
