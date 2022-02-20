//
//  ProfileVC.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/19.
//

import UIKit

import RxSwift

class ProfileVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.naviAndTabbar()
        
        self.bindState(viewModel: self.viewModel)
        self.bindAction(viewModel: self.viewModel)
        
        self.loginButton?.cornerRound(radius: 4)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateUI()
        self.viewModel.requestUserInfo()
        self.viewModel.requestStarRepo(with: true)
    }
    
    private func naviAndTabbar() {
        
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(),
                                                                    for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.tabBarController?.tabBar.isTranslucent = true
        self.tabBarController?.tabBar.backgroundImage = UIImage()
        self.tabBarController?.tabBar.shadowImage = UIImage()
    }
    
    private func updateUI() {
        
        self.loginBarButton?.title = UserInfo.shared.apiToken == "" ?
                                     "로그인" : "로그아웃"
        
        self.loginGuideLabel?.isHidden = UserInfo.shared.apiToken != ""
        self.loginButton?.isHidden     = UserInfo.shared.apiToken != ""
        
        self.userInfoView?.isHidden      = UserInfo.shared.apiToken == ""
        self.starRepoTableView?.isHidden = UserInfo.shared.apiToken == ""
    }
    
    private let viewModel: ProfileVMProtocol = ProfileVM()
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var loginBarButton: UIBarButtonItem?
    
    @IBOutlet private weak var loginGuideLabel: UILabel?
    @IBOutlet private weak var loginButton: UIButton?
    
    @IBOutlet private weak var userInfoView: UIView?
    @IBOutlet private weak var userImageView: UIImageView?
    @IBOutlet private weak var userNameLabel: UILabel?
    @IBOutlet private weak var userCompanyLabel: UILabel?
    @IBOutlet private weak var userFollowInfoLabel: UILabel?
    
    @IBOutlet private var starRepoTableView: UITableView!
}

extension ProfileVC {
    
    private func bindState(viewModel: ProfileVMProtocol) {
        
        viewModel.userName
            .bind { [weak self] in
                
                self?.userNameLabel?.text = $0
            }
            .disposed(by: self.disposeBag)
        
//        viewModel.userName
//            .bind { [weak self] in
//
//                self?.userNameLabel?.text = $0
//            }
//            .disposed(by: self.disposeBag)
        
        viewModel.userCompany
            .map { $0 == "" ? "없음" : $0 }
            .bind { [weak self] in
                
                self?.userCompanyLabel?.text = $0
            }
            .disposed(by: self.disposeBag)
        
        Observable.zip(viewModel.userFollowers,
                       viewModel.userFollowing)
            .bind { [weak self] followers, following in
                
                self?.userFollowInfoLabel?.text = "\(followers) followers · " +
                                                  "\(following) following"
            }
            .disposed(by: self.disposeBag)
        
        viewModel.starRepos
            .bind(to: self.starRepoTableView.rx.items(cellIdentifier: RepositoryCell.identifier,
                                                      cellType: RepositoryCell.self)) {
                
                index, item, cell in
                
                cell.updateUI(repository: item,
                              index: index)
                cell.repoStarDelegate = self
            }
            .disposed(by: self.disposeBag)
    }
    
    private func bindAction(viewModel: ProfileVMProtocol) {
        
        self.loginBarButton?.rx.tap
            .bind { UserInfo.shared.checkAPIToken() }
            .disposed(by: self.disposeBag)
    }
}

extension ProfileVC: RepoStarDelegate {
    
    func didTapStar(with index: Int) {
        
        self.viewModel.requestDeleteStar(At: index)
    }
}
