//
//  UILabel+Extension.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/19.
//

import UIKit

extension UILabel {
    
    func changeTextColorAndFont(changeTexts: [String],
                                colors: [UIColor?],
                                fonts: [UIFont?]) {
        
        guard let labelText = self.text else { return }
        
        let attributedString = NSMutableAttributedString(string: labelText)
        
        for i in 0..<changeTexts.count {
            
            if let color = colors[i] {
                
                attributedString.addAttribute(
                    .foregroundColor,
                    value: color,
                    range: (labelText as NSString).range(of: changeTexts[i])
                )
            }
            
            if let font = fonts[i] {
                
                attributedString.addAttribute(
                    .font,
                    value: font,
                    range: (labelText as NSString).range(of: changeTexts[i])
                )
            }
        }
        
        self.attributedText = attributedString
    }
    
    // MARK: -- Builder
    static func create() -> UILabel {
                
        return UILabel()
    }
    
    func withText(_ text: String?) -> UILabel {
        
        self.text = text
        return self
    }
    
    func withTextColor(_ color: UIColor) -> UILabel {

        self.textColor = color
        return self
    }
    
    func withFont(_ font: UIFont) -> UILabel {
        
        self.font = font
        return self
    }
    
    func withAlignment(_ alignment: NSTextAlignment) -> UILabel {
        
        self.textAlignment = alignment
        return self
    }

}
