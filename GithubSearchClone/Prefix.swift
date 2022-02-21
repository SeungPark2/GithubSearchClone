//
//  Prefix.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/18.
//

import Foundation

struct Server {
    
    static let url: String    = "https://api.github.com"
    static let github: String = "https://github.com"
}

struct Root {
    
    static let search: String = "/search"
    static let login: String  = "/login"
    static let oauth: String  = "/oauth"
    static let user: String   = "/user"
}

struct EndPoint {
    
    static let repositories: String = "/repositories"
    static let authorize: String    = "/authorize"
    static let accessToken: String  = "/access_token"
    static let startList: String    = "/starred"
}
