//
//  Repository.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/18.
//

import Foundation

struct Repositories: Codable {
    
    let totalCount: Int?
    let items: [Repository]
    
    enum CodingKeys: String, CodingKey {
        
        case totalCount = "total_count"
        case items
    }
}

struct Repository: Codable {
    
    let id: Int?
    let owner: Owner
    let starCount: Int?
    let license: License
    @DefaultEmptyString var name: String
    @DefaultEmptyString var language: String
    @DefaultEmptyString var introduce: String
    @DefaultEmptyString var visibility: String
    
    enum CodingKeys: String, CodingKey {
        
        case id, name, owner, language, visibility, license
        case starCount = "stargazers_count"
        case introduce = "description"
    }
}

struct Owner: Codable {
    
    @DefaultEmptyString var name: String
    let id: Int?
    
    enum CodingKeys: String, CodingKey {
        
        case name = "login"
        case id
    }
}

struct License: Codable {
    
    @DefaultEmptyString var key: String
    @DefaultEmptyString var name: String
    @DefaultEmptyString var url: String
}
