//
//  UIView+Extension.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/18.
//

import UIKit

enum ConstraintPosition {
    case top
    case bottom
    case leading
    case trailing
}

extension UIView {
    
    func cornerRound(radius: CGFloat? = nil) {
        
        self.layer.masksToBounds = true
        
        guard let radius = radius else {
            
            self.layer.cornerRadius = self.bounds.height / 2
            return
        }
        
        self.layer.cornerRadius = radius
    }
}
