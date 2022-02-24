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
    
    var starRepos: BehaviorRelay<[Repository]> { get }
    
    var isHiddenEmptyText: BehaviorRelay<Bool> { get }
    
    func refresh()
    func requestStarRepo()
    func requestChangeStar(at index: Int)
}

class ProfileVM: ProfileVMProtocol {
    
    // MARK: -- Public Properties
    
    var isLoaded = BehaviorRelay<Bool>(value: true)
    var errMsg = BehaviorRelay<String>(value: "")
    
    var user = BehaviorRelay<User?>(value: nil)    
    
    var starRepos = BehaviorRelay<[Repository]>(value: [])
    
    var isHiddenEmptyText = BehaviorRelay<Bool>(value: true)
    
    init() {
        
        if UserInfo.shared.apiToken != "" {
            
            self.refresh()
        }
    }
    
    // MARK: -- Public Method
    
    func refresh() {
        
        guard UserInfo.shared.apiToken != "",
              !self.isLoadingStarRepoNextPage else {
            
            return
        }
        
        self.isLoaded.accept(false)
        self.isLoadingStarRepoNextPage = true
        self.isHiddenEmptyText.accept(true)
        
        self.user.accept(nil)
        self.starRepos.accept([])
        self.starRepoNextPage = 1
        
        let userInfoAPI = Network.shared.requestGet(with: Root.user,
                                                    query: nil)
        
        let starReposAPI = Network.shared.requestGet(with: Root.user + EndPoint.startList,
                                                     query: ["per_page": 10,
                                                             "page": 1])
        
        Observable.zip(userInfoAPI,
                       starReposAPI)
            .subscribe(
                onNext: {
                    
                    [weak self] userInfo, repos in
                     
                    let user = try? JSONDecoder().decode(User.self, from: userInfo.data)
                    let repo = try? JSONDecoder().decode([Repository].self, from: repos.data)
                    
                    self?.user.accept(user)
                    
                    var repositories = repo ?? []
                    
                    let repoCount: Int = repositories.count
                    for i in 0..<repoCount {
                        
                        repositories[i].isAddedStart = true
                    }
                    
                    if (self?.starRepoNextPage ?? 0) > 1 {

                        repositories = (self?.starRepos.value ?? []) + (repo ?? [])
                    }

                    self?.starRepos.accept(repositories)
                    
                    self?.isHiddenEmptyText.accept(!repositories.isEmpty)
                    
                    self?.starRepoNextPage = repos.isHadNextPage ?
                                             (self?.starRepoNextPage ?? 0) + 1 :
                                             nil                    

                    self?.isLoaded.accept(true)
                    self?.isLoadingStarRepoNextPage = false
                    
                },
                onError: {
                    
                    _ in
                    
                })
            .disposed(by: self.disposeBag)
    }
    
    func requestStarRepo() {
        
        guard UserInfo.shared.apiToken != "",
              let nextPage = self.starRepoNextPage,
              !self.isLoadingStarRepoNextPage else {
            
            return
        }
        
        self.isLoaded.accept(false)
        self.isLoadingStarRepoNextPage = true
        
        Network.shared.requestGet(with: Root.user + EndPoint.startList,
                                  query: ["per_page": 10,
                                          "page": nextPage])
            .map { [weak self] response in
                
                self?.starRepoNextPage = response.isHadNextPage ?
                                         nextPage + 1 : nil
                
                return response.data
            }
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
                    self?.isLoadingStarRepoNextPage = false
            },
                onError: { [weak self] in
                
                    self?.errMsg.accept(
                        (($0 as? Network.NetworkError)?.description) ?? ""
                    )
                    self?.isLoaded.accept(true)
                    self?.isLoadingStarRepoNextPage = false
            })
            .disposed(by: self.disposeBag)
    }
    
    func requestChangeStar(at index: Int) {
        
        guard let selectedRepo = self.starRepos.value[safe: index],
              let isAdded = self.starRepos.value[safe: index]?.isAddedStart else {
            
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
                    
                    var copyRepos = self?.starRepos.value
                    
                    copyRepos?[index].isAddedStart = !isAdded
                    
                    self?.starRepos.accept(copyRepos ?? [])
                    self?.isLoaded.accept(true)
                    
                    isAdded ? UserInfo.shared.addStarRepo(selectedRepo) :
                              UserInfo.shared.removeStarRepo(selectedRepo)
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
    
    private var starRepoNextPage: Int? = 1
    private var isLoadingStarRepoNextPage: Bool = false
    private let disposeBag = DisposeBag()
}
