//
//  String+Extension.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/19.
//

import Foundation

extension String {
    
    /*
     <https://api.github.com/user/starred?page=2&per_page=10>; rel="prev",
     <https://api.github.com/user/starred?page=2&per_page=10>; rel="last",
     <https://api.github.com/user/starred?page=1&per_page=10>; rel="first"
     */
    
    func findNextPage() -> Bool {
        
        let links = self.components(separatedBy: ",")

        var linkDictionary: [String: String] = [:]
        
        links.forEach({
            
            let components = $0.components(separatedBy:"; ")
            linkDictionary[components[1]] = components[0]
        })

        return linkDictionary["rel=\"next\""] != nil
    }
}
