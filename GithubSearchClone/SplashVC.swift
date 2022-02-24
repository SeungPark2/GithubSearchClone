//
//  SplashVC.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/22.
//

import UIKit

import RxSwift

class SplashVC: UIViewController {
    
    // MARK: -- Public Properties
    
    // MARK: -- Public Method
    
    // MARK: -- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.requestStarRepo()
        
        self.repoLoaded
            .filter { $0 }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] _ in
                
                self?.dismiss(animated: true,
                              completion: nil)
                NotificationCenter.default.post(name: .changeLogin,
                                                object: nil)
            }
            .disposed(by: self.disposeBag)
    }
    
    // MARK: -- Private Method
    
    private func requestStarRepo() {
        
        guard let nextPage = nextPage else {
            
            return
        }
        
        Network.shared.requestGet(with: Root.user + EndPoint.startList,
                                  query: ["page": nextPage, "per_page": 10])
            .map { [weak self] response -> Data in
                
                self?.nextPage = response.isHadNextPage ? nextPage + 1 : nil
                
                return response.data
            }
            .decode(type: [Repository].self, decoder: JSONDecoder())
            .subscribe(
                onNext: {

                [weak self] repos in
                
                UserInfo.shared.starRepos = UserInfo.shared.starRepos + repos
                
                self?.nextPage == nil ? self?.repoLoaded.onNext(true) :
                                        self?.requestStarRepo()
            },
                onError: { [weak self] _ in
             
                    self?.dismiss(animated: true,
                                  completion: nil)
            })
            .disposed(by: self.disposeBag)
    }
    
    // MARK: -- Private Properties
    
    private var repoLoaded = BehaviorSubject<Bool>(value: false)
    private var nextPage: Int? = 1
    private let disposeBag = DisposeBag()
}
