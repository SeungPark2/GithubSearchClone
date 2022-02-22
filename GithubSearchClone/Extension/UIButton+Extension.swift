//
//  UIButton+Extension.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/19.
//

import UIKit

extension UIButton {
    
    // MARK: -- Builder
    static func create() -> UIButton {
                
        return UIButton()
    }
    
    func withText(_ text: String?) -> UIButton {
        
        self.setTitle(text,
                      for: .normal)
        return self
    }
    
    func withTextColor(_ color: UIColor) -> UIButton {

        self.setTitleColor(color,
                           for: .normal)
        return self
    }
    
    func withFont(_ font: UIFont) -> UIButton {
        
        self.titleLabel?.font = font
        return self
    }
    
    func withImage(_ image: UIImage) -> UIButton {
        
        self.setImage(image,
                      for: .normal)
        return self
    }    
    
    func withTitlePadding(_ edgeInsets: UIEdgeInsets) -> UIButton {
        
        self.titleEdgeInsets = edgeInsets
        return self
    }
    
    func withAlignment(_ alignment: ContentHorizontalAlignment) -> UIButton {
        
        self.contentHorizontalAlignment = alignment
        return self
    }

}
