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
    
    var userName: BehaviorRelay<String> { get }
    var userCompany: BehaviorRelay<String> { get }
    var userImageURL: BehaviorRelay<String> { get }
    var userFollowers: BehaviorRelay<Int> { get }
    var userFollowing: BehaviorRelay<Int> { get }
    
    var starRepos: BehaviorRelay<[Repository]> { get }
    
    func requestUserInfo()
    func requestStarRepo(with viewWillAppear: Bool)
    func requestDeleteStar(At index: Int)
}

class ProfileVM: ProfileVMProtocol {
    
    var isLoaded = BehaviorRelay<Bool>(value: true)
    var errMsg = BehaviorRelay<String>(value: "")
    
    var userName = BehaviorRelay<String>(value: "")
    var userCompany = BehaviorRelay<String>(value: "")
    var userImageURL = BehaviorRelay<String>(value: "")
    var userFollowers = BehaviorRelay<Int>(value: 0)
    var userFollowing = BehaviorRelay<Int>(value: 0)
    
    var starRepos = BehaviorRelay<[Repository]>(value: [])
    
    func requestUserInfo() {
        
        if UserInfo.shared.apiToken != "",
           userName.value == "" {
            
            Network.shared.requestGet(with: Root.user,
                                      query: nil)
                .decode(type: User.self, decoder: JSONDecoder())
                .observe(on: MainScheduler.instance)
                .subscribe(
                    onNext: { [weak self] userInfo in
                        
                        self?.userImageURL.accept(userInfo.imageURL)
                        self?.userName.accept(userInfo.name)
                        self?.userCompany.accept(userInfo.company)
                        
                        self?.userFollowers.accept(userInfo.followers ?? 0)
                        self?.userFollowing.accept(userInfo.following ?? 0)
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
        
        if viewWillAppear {
            
            self.repoNextPage = 1
        }
        
        guard let nextPage = self.repoNextPage,
              !self.isLoadingRepoNextPage,
              UserInfo.shared.apiToken != "" else {
            
            return
        }
        
        self.isLoaded.accept(false)
        self.isLoadingRepoNextPage = true
        
        Network.shared.requestGet(with: Root.user + EndPoint.startList,
                                  query: ["per_page": 10,
                                          "page": nextPage])
            .decode(type: [Repository].self, decoder: JSONDecoder())
            .subscribe(
                onNext: { [weak self] repo in
                
                    var repositories = repo
                    
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
    
    func requestDeleteStar(At index: Int) {
        
        guard let repoName = self.starRepos.value[safe: index]?.name else {
            
            return
        }
        
        Network.shared.requestBody(with: Root.user +
                                         EndPoint.startList +
                                         "/\(self.userName.value)/\(repoName)",
                                   params: [:],
                                   httpMethod: .delete)
            .subscribe(
                onNext: { [weak self] _ in
                    
                    var copyRepos = self?.starRepos.value
                    
                    copyRepos?.remove(at: index)
                    
                    self?.starRepos.accept(copyRepos ?? [])
            },
                onError: { [weak self] _ in
                    
                    self?.errMsg.accept("스타 해제에 실패했습니다. \n다시 시도해주세요.")
            })
            .disposed(by: self.disposeBag)
    }
    
    private var repoNextPage: Int? = 1
    private var isLoadingRepoNextPage: Bool = false
    private let disposeBag = DisposeBag()
}
