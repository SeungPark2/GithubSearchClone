//
//  ProfileVC.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/19.
//

import UIKit

import RxSwift
import Kingfisher

class ProfileVC: UIViewController {
    
    // MARK: -- Public Properties
    
    // MARK: -- Public Method
    
    // MARK: -- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.naviAndTabbar()
        
        self.bindState(viewModel: self.viewModel)
        self.bindAction(viewModel: self.viewModel)
        
        self.loginButton?.cornerRound(radius: 4)
        self.userImageView?.cornerRound()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateUI()
        
        if UserInfo.shared.apiToken != "" {
            
            self.viewModel.requestUserInfo()
            self.viewModel.requestStarRepo(with: true)
        }
    }
    
    // MARK: -- Private Method
    
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
    
    private func downloadImage(with imageURL: String) {
        
        KF.url(URL(string: imageURL))
          .loadDiskFileSynchronously()
          .cacheMemoryOnly()
          .fade(duration: 0.25)
          .onFailure { error in print(error.localizedDescription) }
          .set(to: self.userImageView ?? UIImageView())
    }
    
    private func updateLoginGuideTitle(with repos: [Repository]?) {
        
        if UserInfo.shared.apiToken == "" {
            
            self.loginGuideLabel?.text = "로그인이 필요합니다."
            return
        }
        
        if repos == nil || repos?.count == 0 {
            
            self.loginGuideLabel?.text = ErrorMessage.registerInterestRepo
            self.loginGuideLabel?.isHidden = false
            return
        }
        
        self.loginGuideLabel?.isHidden = true
    }
    
    // MARK: -- Private Properties
    
    private let viewModel: ProfileVMProtocol = ProfileVM()
    private let disposeBag = DisposeBag()
    
    // MARK: -- IBoutlet
    
    @IBOutlet private weak var loginBarButton: UIBarButtonItem?
    
    @IBOutlet private weak var loginGuideLabel: UILabel?
    @IBOutlet private weak var loginButton: UIButton?
    
    @IBOutlet private weak var userInfoView: UIView?
    @IBOutlet private weak var userImageView: UIImageView?
    @IBOutlet private weak var userNameLabel: UILabel?
    @IBOutlet private weak var userCompanyLabel: UILabel?
    @IBOutlet private weak var userFollowInfoLabel: UILabel?
    
    @IBOutlet private var starRepoTableView: UITableView!
    
    @IBOutlet private weak var loadingIndicatorView: UIActivityIndicatorView?
}

extension ProfileVC {
    
    // MARK: -- BindState
    
    private func bindState(viewModel: ProfileVMProtocol) {
        
        viewModel.isLoaded
            .observe(on: MainScheduler.instance)
            .bind { [weak self] in
                
                $0 ? self?.loadingIndicatorView?.stopAnimating() :
                     self?.loadingIndicatorView?.startAnimating()
                self?.loadingIndicatorView?.isHidden = $0
            }
            .disposed(by: self.disposeBag)
        
        viewModel.errMsg
            .filter { $0 != "" }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] message in
                
                self?.showAlert(content: message)
            }
            .disposed(by: self.disposeBag)
        
        viewModel.userName
            .observe(on: MainScheduler.instance)
            .bind { [weak self] in
                
                self?.userNameLabel?.text = $0
            }
            .disposed(by: self.disposeBag)
        
        viewModel.userImageURL
            .filter { $0 != "" }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] in

                self?.downloadImage(with: $0)
            }
            .disposed(by: self.disposeBag)
        
        viewModel.userCompany
            .map { $0 == "" ? "없음" : $0 }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] in
                
                self?.userCompanyLabel?.text = $0
            }
            .disposed(by: self.disposeBag)
        
        Observable.zip(viewModel.userFollowers,
                       viewModel.userFollowing)
            .observe(on: MainScheduler.instance)
            .bind { [weak self] followers, following in
                
                self?.userFollowInfoLabel?.text = "\(followers) followers · " +
                                                  "\(following) following"
            }
            .disposed(by: self.disposeBag)
        
        viewModel.starRepos
            .observe(on: MainScheduler.instance)
            .map { [weak self] repos -> [Repository]? in
                
                self?.updateLoginGuideTitle(with: repos)
                return repos
            }
            .filter { $0 != nil }
            .map { $0 ?? [] }
            .bind(to: self.starRepoTableView.rx.items(cellIdentifier: RepositoryCell.identifier,
                                                      cellType: RepositoryCell.self)) {
                
                index, item, cell in
                
                cell.updateUI(repository: item,
                              index: index)
                cell.repoStarDelegate = self
            }
            .disposed(by: self.disposeBag)
    }
    
    // MARK: -- BindAction
    
    private func bindAction(viewModel: ProfileVMProtocol) {
        
        self.loginBarButton?.rx.tap
            .bind { UserInfo.shared.checkAPIToken() }
            .disposed(by: self.disposeBag)
        
        self.loginButton?.rx.tap
            .bind { UserInfo.shared.checkAPIToken() }
            .disposed(by: self.disposeBag)
    }
}

// MARK: -- RepoStarDelegate

extension ProfileVC: RepoStarDelegate {
    
    func didTapStar(with index: Int) {
        
        self.viewModel.requestDeleteStar(At: index)
    }
}
