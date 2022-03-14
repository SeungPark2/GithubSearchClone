//
//  APIRequest.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/03/14.
//

import Foundation

struct APIRequest {
    
    let method: HTTPMethod
    let url: URL
}

extension APIRequest {
    
    func create(with apiToken: String?) -> URLRequest {
        
        var request = URLRequest(url: self.url)
        request.httpMethod = method.rawValue
        
        request.setValue("application/json;charset=UTF-8",
                         forHTTPHeaderField: "Content-Type")
        request.setValue("application/vnd.github.v3+json",
                         forHTTPHeaderField: "Accept")
        
        if let apiToken = apiToken {
            
            request.setValue("Bearer \(apiToken)",
                             forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
}
