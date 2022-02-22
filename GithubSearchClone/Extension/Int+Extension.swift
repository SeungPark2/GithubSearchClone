//
//  Int+Extension.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/18.
//

import Foundation

extension Int {
    
    func convertToKilo() -> String {
        
        if self > 999 {
            
            return String(format: "%.1f", (Double(self) / 1000)) + "k"
        }
        
        return "\(self)"
    }
}
