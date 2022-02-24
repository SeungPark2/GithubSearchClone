//
//  HttpMethod.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/24.
//

import Foundation

extension Network {
    
    enum HttpMethod: String {
        
        case get    = "GET"
        case post   = "POST"
        case put    = "PUT"
        case delete = "DELETE"
    }

}
