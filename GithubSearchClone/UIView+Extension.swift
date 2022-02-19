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
    
    func top(target: UIView?,
             targetPosition: ConstraintPosition,
             constant: CGFloat = 0) {
        
        switch targetPosition {
        
            case .top:
                
                self.topAnchor.constraint(equalTo: target?.topAnchor ?? NSLayoutYAxisAnchor(),
                                          constant: constant).isActive = true
            case .bottom:
                
                self.topAnchor.constraint(equalTo: target?.bottomAnchor ?? NSLayoutYAxisAnchor(),
                                          constant: constant).isActive = true
        default:
            break
        }
    }
    
    func bottom(target: UIView?,
                targetPosition: ConstraintPosition,
                constant: CGFloat = 0) {
        
        switch targetPosition {
        
            case .top:
                
                self.bottomAnchor.constraint(equalTo: target?.topAnchor  ?? NSLayoutYAxisAnchor(),
                                             constant: constant).isActive = true
            case .bottom:
                
                self.bottomAnchor.constraint(equalTo: target?.bottomAnchor  ?? NSLayoutYAxisAnchor(),
                                             constant: constant).isActive = true
        default:
            break
        }
    }
    
    func leading(target: UIView?,
                 targetPosition: ConstraintPosition,
                 constant: CGFloat = 0) {
        
        switch targetPosition {
        
            case .leading:
                
                self.leadingAnchor.constraint(equalTo: target?.leadingAnchor ?? NSLayoutXAxisAnchor(),
                                              constant: constant).isActive = true
            case .trailing:
                
                self.leadingAnchor.constraint(equalTo: target?.trailingAnchor ?? NSLayoutXAxisAnchor(),
                                              constant: constant).isActive = true
        default:
            break
        }
    }
    
    func trailing(target: UIView?,
                  targetPosition: ConstraintPosition,
                  constant: CGFloat = 0) {
        
        switch targetPosition {
        
            case .leading:
                
                self.trailingAnchor.constraint(equalTo: target?.leadingAnchor ?? NSLayoutXAxisAnchor(),
                                               constant: constant).isActive = true
            case .trailing:
                
                self.trailingAnchor.constraint(equalTo: target?.trailingAnchor ?? NSLayoutXAxisAnchor(),
                                               constant: constant).isActive = true
        default:
            break
        }
    }
}
