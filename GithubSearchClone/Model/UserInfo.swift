//
//  UserInfo.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/18.
//

import UIKit

import RxSwift

class UserInfo {
    
    static let shared: UserInfo = UserInfo()
    private init() {
        
        self._apiToken = UserDefaults.standard.string(forKey: self.apiTokenKey)
    }
    
    // MARK: -- Public Properties
    
    var apiToken: String {
        
        get { return self._apiToken ?? "" }
    }
    
    var starRepos: [Repository] = []
    
    // MARK: -- Public Method
    
    func checkAPIToken() {
        
        if self.apiToken == "" {
            
            self.requestGithubCode()
            return
        }
        
        self.logout()
        UIApplication.topViewController()?.viewWillAppear(true)
    }
    
    func addStarRepo(_ repo: Repository) {
        
        if self.starRepos.firstIndex(where: { $0.id == repo.id }) == nil {
            
            self.starRepos.append(repo)
        }
    }
    
    func removeStarRepo(_ repo: Repository) {
        
        if let index = self.starRepos.firstIndex(where: { $0.id == repo.id }) {
            
            self.starRepos.remove(at: index)
        }
    }
    
    // MARK: -- Private Method
    
    private func logout() {
        
        self._apiToken = nil
        UserDefaults.standard.setValue(nil,
                                       forKey: self.apiTokenKey)
        self.starRepos.removeAll()
    }
    
    func requestAPIToken(code: String) {
        
        Network.shared.requestBody(serverURL: Server.github,
                                   with: Root.login +
                                         Root.oauth +
                                         EndPoint.accessToken,
                                   params: ["client_id": "3669b2d1f5122ce49bbe",
                                            "client_secret": "d5f08702a7541b2d7e05f5f8ba70ff84a4442277",
                                            "code": code],
                                   httpMethod: .post)
            .subscribe(
                onNext: { [weak self] data in
                    
                    let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    
                    print("json \(json ?? [:])")
                    
                    self?._apiToken = (json?["access_token"] as? String) ?? ""
                    UserDefaults.standard.setValue(self?._apiToken,
                                                   forKey: self?.apiTokenKey ?? "")
                    
                    DispatchQueue.main.async {
                    
                        let vc = UIApplication.topViewController()
                        
                        vc?.viewWillAppear(true)
                        vc?.showSplashVC()
                    }
                },
                onError: {
                    
                    print($0.localizedDescription)
                    DispatchQueue.main.async {
                        
                        UIApplication.topViewController()?.showAlert(content: ErrorMessage.failedLogin)
                    }
                })
            .disposed(by: self.disposeBag)
    }
    
    private func requestGithubCode() {
        
        let scope = "repo,user"
        
        let urlString = Server.github +
                        Root.login +
                        Root.oauth +
                        EndPoint.authorize + "?client_id=\("3669b2d1f5122ce49bbe")&scope=\(scope)"
        
        if let url = URL(string: urlString),
           UIApplication.shared.canOpenURL(url) {
            
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: -- Private Properties
    
    private var _apiToken: String? = nil
    private let apiTokenKey: String = "apiTokenKey"
    
    private let disposeBag = DisposeBag()
}
