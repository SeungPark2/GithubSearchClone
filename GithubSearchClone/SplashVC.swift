//
//  SplashVC.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/22.
//

import UIKit

import RxSwift
import SnapKit

class SplashVC: UIViewController {
    
    // MARK: -- Public Properties
    
    // MARK: -- Public Method
    
    // MARK: -- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addViews()
        self.makeViewsConstraints()
        self.updateUI()
        
        self.bindState()
        
        self.requestStarRepo()
    }
    
    // MARK: -- Private Method
    
    private func addViews() {
        
        self.view.addSubview(self.logoImageView)
        self.view.addSubview(self.stateLabel)
    }

    private func makeViewsConstraints() {
        
        self.logoImageView.snp.makeConstraints {
            
            $0.center.equalToSuperview()
        }
        
        self.stateLabel.snp.makeConstraints {
            
            $0.top.equalTo(self.logoImageView.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func updateUI() {
        
        self.view.backgroundColor = #colorLiteral(red: 0.2509803922, green: 0.2509803922, blue: 0.2509803922, alpha: 1)
    }
    
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
    
    private let logoImageView = UIImageView(image: #imageLiteral(resourceName: "icons8-github-100.png"))
    private lazy var stateLabel: UILabel = {
       
        let label = UILabel()
        label.textColor = .white
        label.text = "유저정보를 불러오는 중입니다."
        
        return label
    }()
    
    private var repoLoaded = BehaviorSubject<Bool>(value: false)
    private var nextPage: Int? = 1
    private let disposeBag = DisposeBag()
}

extension SplashVC {
    
    private func bindState() {
        
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
}
