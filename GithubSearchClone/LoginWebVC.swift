//
//  LoginWebVC.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/19.
//

import UIKit
import WebKit

import RxSwift

//protocol NiceCertifyDelegate {
//
//    func certifySuccess(niceInfo: NiceInfo)
//    func ageLimit()
//    func notAllowForeigner()
//    func alreadyJoined()
//    func certifyFailure()
//}

class LoginWebVC: UIViewController {
            
//    var niceDelegate: NiceCertifyDelegate?
    
    private var titleView: UIView?
    private var webView: WKWebView?
    private var popupWebView: WKWebView?
    
        
    private let disposeBag = DisposeBag()
    private let clientID: String = "3669b2d1f5122ce49bbe"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.connectWebView()
    }
    
    func connectWebView() {
        
        self.view.backgroundColor = #colorLiteral(red: 0.1308166683, green: 0.1535792947, blue: 0.181928426, alpha: 1)
        
        let config = WKWebViewConfiguration()
        
        let top: CGFloat = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0.0
        let bottom: CGFloat = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0.0
        
        self.createTitleView(safeAreaTop: top)
                        
        self.webView = WKWebView(frame: CGRect(x: 0,
                                               y: top + 60,
                                               width: self.view.bounds.width,
                                               height: self.view.bounds.height - (top + 60 + bottom)),
                                 configuration: config)
        self.webView?.uiDelegate = self
        self.webView?.navigationDelegate = self
        self.webView?.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        self.view.addSubview(self.webView ?? WKWebView())
        
        guard let url = URL(string: "https://github.com/login/oauth/authorize?client_id=\(self.clientID)&scope=repo,user") else {
            
            return
        }
        
        self.webView?.load(URLRequest(url: url))
    }
    
    private func createTitleView(safeAreaTop: CGFloat) {
        
        self.titleView = UIView(frame: CGRect(x: 0,
                                              y: safeAreaTop,
                                              width: self.view.bounds.width,
                                              height: 40))
        self.view.addSubview(self.titleView ?? UIView())
        
        let titleLabel = UILabel.create()
                                .withText("깃헙 로그인")
                                .withFont(.systemFont(ofSize: 18))
                                .withTextColor(.white)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleView?.addSubview(titleLabel)
        titleLabel.centerYAnchor.constraint(equalTo: self.titleView?.centerYAnchor ?? NSLayoutYAxisAnchor())
            .isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: self.titleView?.centerXAnchor ?? NSLayoutXAxisAnchor())
            .isActive = true
        
        let closeButton = UIButton.create()
                                  .withImage(#imageLiteral(resourceName: "close"))
    
        closeButton.addTarget(self,
                              action: #selector(self.didTapClose),
                              for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        self.titleView?.addSubview(closeButton)
        
        closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        closeButton.trailing(target: self.titleView,
                             targetPosition: .trailing,
                             constant: -20)
    }
    
    @objc
    private func didTapClose() {
        
        self.popupWebView?.removeFromSuperview()
        self.webView?.removeFromSuperview()
        
        self.dismiss(animated: true,
                     completion: nil)
    }
}

extension LoginWebVC: WKUIDelegate, WKNavigationDelegate {
    
//    func webView(_ webView: WKWebView,
//                 didFinish navigation: WKNavigation!) {
//
//
//        self.webView?.removeFromSuperview()
//        self.popupWebView?.removeFromSuperview()
//    }
//
//    func webView(_ webView: WKWebView,
//                 createWebViewWith configuration: WKWebViewConfiguration,
//                 for navigationAction: WKNavigationAction,
//                 windowFeatures: WKWindowFeatures) -> WKWebView? {
//
//        self.popupWebView = WKWebView(frame: self.webView?.frame ?? CGRect(),
//                                 configuration: configuration)
//        self.popupWebView?.autoresizingMask = [.flexibleWidth,
//                                               .flexibleHeight]
//        self.popupWebView?.navigationDelegate = self
//        self.popupWebView?.uiDelegate = self
//
//        view.addSubview(self.popupWebView ?? WKWebView())
//
//        return self.popupWebView
//    }
}
