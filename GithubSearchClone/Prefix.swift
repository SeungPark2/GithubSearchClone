//
//  Prefix.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/18.
//

import Foundation

struct Server {
    
    static let url    = "https://api.github.com"
    static let github = "https://github.com"
}

struct Root {
    
    static let search = "/search"
    static let login  = "/login"
    static let oauth  = "/oauth"
    static let user   = "/user"
}

struct EndPoint {
    
    static let repositories = "/repositories"
    static let authorize    = "/authorize"
    static let accessToken  = "/access_token"
    static let startList    = "/starred"
}
