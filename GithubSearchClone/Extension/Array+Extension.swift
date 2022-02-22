//
//  Array+Extension.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/18.
//

import Foundation

extension Array {
    
    subscript (safe index: Int) -> Element? {

        return indices ~= index ? self[index] : nil
    }
}
