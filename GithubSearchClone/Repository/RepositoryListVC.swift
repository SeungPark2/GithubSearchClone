//
//  RepositoryListVC.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/18.
//

import UIKit

import RxSwift

class RepositoryListVC: UIViewController {

    // MARK: -- Public Properties
    
    // MARK: -- Public Method
    
    // MARK: -- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if UserInfo.shared.apiToken != "" {
            
            showSplashVC()
        }
        
        self.naviAndTabbar()
        self.addNotification()
        
        self.bindState(with: self.viewModel)
        self.bindAction(with: self.viewModel)
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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.updateUIWhenChangeLogin),
                                               name: .changeLogin,
                                               object: nil)
    }
    
    @objc
    private func updateUIWhenChangeLogin() {
        
        self.loginButton?.image = UserInfo.shared.apiToken == "" ?
                                  UIImage(named: "login") :
                                  UIImage(named: "logout")
        
        self.viewModel.refreshRepo()
    }
    
    @objc
    private func refreshRepo() {
        
        self.viewModel.refreshRepo()
        self.loadingIndicatorView?.isHidden = true
    }
    
    // MARK: -- Private Properties
    
    private lazy var searchController: UISearchController = {
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "저장소명 검색"
        searchController.searchBar.setValue("취소",
                                            forKey: "cancelButtonText")
        searchController.searchBar.tintColor = .white
        searchController.searchBar.searchTextField.leftView?.tintColor = .lightGray
        searchController.hidesNavigationBarDuringPresentation = false

        self.navigationItem.searchController = searchController
        
        return searchController
    }()
    
    private let viewModel: RepositoryListVMProtocol = RepositoryListVM()
    private let disposeBag = DisposeBag()
    
    private lazy var refreshControl: UIRefreshControl = {
       
        let refresh = UIRefreshControl()
        refresh.addTarget(self,
                          action: #selector(self.refreshRepo),
                          for: .valueChanged)
        return refresh
    }()
    
    // MARK: -- IBOutlet
    
    @IBOutlet private weak var loginButton: UIBarButtonItem?
    
    @IBOutlet private var repositoryTableView: UITableView!
    @IBOutlet private var fullNameTableView: UITableView!
    
    @IBOutlet private weak var searchEmptyLabel: UILabel?
    @IBOutlet private weak var loadingIndicatorView: UIActivityIndicatorView?
}

extension RepositoryListVC {
    
    // MARK: -- bindState
    
    private func bindState(with viewModel: RepositoryListVMProtocol) {
        
        self.searchController.searchBar.searchTextField.textColor = .white
        self.loginButton?.image = UserInfo.shared.apiToken == "" ?
                                  UIImage(named: "login") :
                                  UIImage(named: "logout")
        
        viewModel.isLoaded
            .observe(on: MainScheduler.instance)
            .bind { [weak self] in
                
                $0 ? self?.loadingIndicatorView?.stopAnimating() :
                     self?.loadingIndicatorView?.startAnimating()
                     self?.loadingIndicatorView?.isHidden = $0
                
                if $0 { self?.refreshControl.endRefreshing() }
            }
            .disposed(by: self.disposeBag)
        
        viewModel.errMsg
            .filter { $0 != "" }
            .observe(on: MainScheduler.instance)
            .bind { [weak self] message in
                
                self?.showAlert(content: message)
            }
            .disposed(by: self.disposeBag)
        
        viewModel.isHiddenFullNames
            .observe(on: MainScheduler.instance)
            .bind { [weak self] in
                
                self?.fullNameTableView.isHidden = $0
            }
            .disposed(by: self.disposeBag)
        
        viewModel.isHiddenEmptyText
            .observe(on: MainScheduler.instance)
            .bind { [weak self] in
                
                self?.searchEmptyLabel?.isHidden = $0
            }
            .disposed(by: self.disposeBag)
        
        viewModel.repositories
            .observe(on: MainScheduler.instance)
            .bind(to: self.repositoryTableView.rx.items(
                        cellIdentifier: RepositoryCell.identifier,
                        cellType: RepositoryCell.self
                      )
            ) {
                
                index, item, cell in
                
                cell.updateUI(repository: item,
                              index: index)
                cell.repoStarDelegate = self
            }
            .disposed(by: self.disposeBag)
        
        viewModel.fullNames
            .observe(on: MainScheduler.instance)            
            .bind(to: self.fullNameTableView.rx.items(
                        cellIdentifier: "FullNameCell"
                      )
            ) {

                index, item, cell in

                cell.textLabel?.text = item.fullName
            }
            .disposed(by: self.disposeBag)
    }
    
    // MARK: -- bindAction
    
    private func bindAction(with viewModel: RepositoryListVMProtocol) {
        
        self.repositoryTableView.addSubview(self.refreshControl)
        
        self.loginButton?.rx.tap
            .bind { UserInfo.shared.checkAPIToken() }
            .disposed(by: self.disposeBag)
        
        self.searchController.searchBar.rx.text
            .distinctUntilChanged()
            .map { $0 ?? "" }
            .filter { $0 != "" && !viewModel.isHiddenFullNames.value }
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind { viewModel.typingWords(with: $0) }
            .disposed(by: self.disposeBag)
        
        self.searchController.searchBar.rx.textDidBeginEditing
            .bind { viewModel.isHiddenEmptyText.accept(true)
                    viewModel.isHiddenFullNames.accept(false) }
            .disposed(by: self.disposeBag)
        
        self.searchController.searchBar.rx.searchButtonClicked
            .map { [weak self] _ -> String in
                
                return self?.searchController.searchBar.searchTextField.text ?? ""
            }
            .bind { viewModel.search(with: $0) }
            .disposed(by: self.disposeBag)
        
        self.searchController.searchBar.rx.cancelButtonClicked
            .bind { viewModel.reset() }
            .disposed(by: self.disposeBag)
        
        self.fullNameTableView.rx.itemSelected
            .map { $0.row }
            .map { viewModel.fullNames.value[safe: $0]?.fullName ?? "" }
            .filter { $0 != "" }
            .bind { [weak self] in
                
                viewModel.search(with: $0)
                self?.searchController.searchBar.searchTextField.text = $0
                self?.searchController.searchBar.searchTextField.resignFirstResponder()
            }
            .disposed(by: self.disposeBag)
        
        self.fullNameTableView.rx.contentOffset
            .filter { [weak self] offset in
                
                guard let `self` = self else { return false }
                guard self.fullNameTableView.frame.height > 0 else { return false }
                
                return self.fullNameTableView.isDragging &&
                      (offset.y + self.fullNameTableView.frame.height >=
                       self.fullNameTableView.contentSize.height + 50)
            }
            .bind { _ in viewModel.requestFullName() }
            .disposed(by: self.disposeBag)
        
        self.fullNameTableView.rx.willBeginDragging
            .bind { [weak self] in
                self?.searchController
                    .searchBar
                    .searchTextField
                    .resignFirstResponder()
            }
            .disposed(by: self.disposeBag)
        
        self.repositoryTableView.rx.contentOffset
            .filter { [weak self] offset in
                
                guard let `self` = self else { return false }
                guard self.repositoryTableView.isDragging else { return false }
                                
                return offset.y + self.repositoryTableView.frame.height >=
                      self.repositoryTableView.contentSize.height + 50
            }
            .bind { _ in viewModel.requestRepo() }
            .disposed(by: self.disposeBag)
    }
}

// MARK: -- RepoStartDelegate

extension RepositoryListVC: RepoStarDelegate {
    
    func didTapStar(with index: Int) {
        
        if UserInfo.shared.apiToken == "" {
            
            showAlert(content: ErrorMessage.login)
            return
        }
        
        self.viewModel.requestChangeStar(with: index)
    }
}
