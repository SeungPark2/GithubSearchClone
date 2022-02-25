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
        self.addNotification()
        
        self.bindState(viewModel: self.viewModel)
        self.bindAction(viewModel: self.viewModel)
        
        self.loginButton?.cornerRound(radius: 4)
        self.updateUIWhenChangeLogin()
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
    
    private func addNotification() {
        
        NotificationCenter
            .default
            .addObserver(self,
                         selector: #selector(self.updateUIWhenChangeLogin),
                         name: .changeLogin,
                         object: nil)
    }
    
    @objc
    private func updateUIWhenChangeLogin() {
        
        self.viewModel.refresh()
        
        self.loginBarButton?.image = UserInfo.shared.apiToken == "" ?
                                     UIImage(named: "login") :
                                     UIImage(named: "logout")
        
        self.loginButton?.isHidden = UserInfo.shared.apiToken != ""
        
        self.starRepoTableView?.isHidden = UserInfo.shared.apiToken == ""
        
        self.loginGuideLabel?.text = UserInfo.shared.apiToken == "" ?
                                     ErrorMessage.login :
                                     ErrorMessage.registerInterestRepo
        
        self.loginGuideLabel?.isHidden = UserInfo.shared.apiToken != ""
    }
    
    @objc
    private func refreshRepo() {
        
        self.viewModel.refresh()
        self.loadingIndicatorView?.isHidden = true
    }
    
    // MARK: -- Private Properties
    
    private let viewModel: ProfileVMProtocol = ProfileVM()
    private let disposeBag = DisposeBag()
    
    private lazy var refreshControl: UIRefreshControl = {
       
        let refresh = UIRefreshControl()
        refresh.addTarget(self,
                          action: #selector(self.refreshRepo),
                          for: .valueChanged)
        return refresh
    }()
    
    // MARK: -- IBoutlet
    
    @IBOutlet private weak var loginBarButton: UIBarButtonItem?
    
    @IBOutlet private weak var loginGuideLabel: UILabel?
    @IBOutlet private weak var loginButton: UIButton?
        
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
                
                if $0 { self?.refreshControl.endRefreshing() }
            }
            .disposed(by: self.disposeBag)
        
        viewModel.isHiddenEmptyText
            .filter { _ in UserInfo.shared.apiToken != "" }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] in
                
                self?.loginGuideLabel?.isHidden = $0
            }
            .disposed(by: self.disposeBag)
        
        viewModel.errMsg
            .filter { $0 != "" }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] message in
                
                self?.showAlert(content: message)
            }
            .disposed(by: self.disposeBag)
        
        viewModel.user
            .observe(on: MainScheduler.instance)
            .bind { [weak self] user in
                
                guard let user = user else {
                    
                    self?.starRepoTableView.tableHeaderView = nil
                    return
                }
                
                let userInfoView = UserInfoView(
                                    frame: CGRect(
                                            x: 0, y: 0,
                                            width: self?.view.bounds.width ?? 0,
                                            height: 120),
                                    user: user
                                   )
                self?.starRepoTableView.tableHeaderView = userInfoView
            }
            .disposed(by: self.disposeBag)
        
        viewModel.starRepos
            .observe(on: MainScheduler.instance)            
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
        
        self.starRepoTableView.addSubview(self.refreshControl)
        
        self.loginBarButton?.rx.tap
            .bind { UserInfo.shared.checkAPIToken() }
            .disposed(by: self.disposeBag)
        
        self.loginButton?.rx.tap
            .bind { UserInfo.shared.checkAPIToken() }
            .disposed(by: self.disposeBag)
        
        self.starRepoTableView.rx.contentOffset
            .filter { [weak self] offset in
                
                guard let `self` = self else { return false }
                guard self.starRepoTableView.isDragging else { return false }
                
                self.tabBarController?.setTabBarHidden(offset.y > 30,
                                                       animated: true)
                
                return offset.y + self.starRepoTableView.frame.height >=
                       self.starRepoTableView.contentSize.height + 50
            }
            .bind { _ in viewModel.requestStarRepo() }
            .disposed(by: self.disposeBag)
    }
}

// MARK: -- RepoStarDelegate

extension ProfileVC: RepoStarDelegate {
    
    func didTapStar(with index: Int) {
        
        self.viewModel.requestChangeStar(at: index)
    }
}
