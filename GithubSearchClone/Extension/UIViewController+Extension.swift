//
//  UIViewController+Extension.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/19.
//

import UIKit

extension UIViewController {
    
    func showAlert(content: String?) {
        
        let alertController = UIAlertController(
                                title: nil,
                                message: content,
                                preferredStyle: .alert
                              )
        
        let closeAction = UIAlertAction(
                            title: "확인",
                            style: .default,
                            handler: nil
                          )
        
        alertController.addAction(closeAction)
        
        self.present(alertController,
                     animated: false,
                     completion: nil)
    }
    
    func showSplashVC() {
        
        if let splashVC = storyboard?.instantiateViewController(withIdentifier: "SplashVC") {
            
            splashVC.modalPresentationStyle = .fullScreen
            self.present(splashVC, animated: false)
        }
    }
}
