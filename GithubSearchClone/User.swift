//
//  User.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/20.
//

import Foundation

struct User: Codable {
    
    @DefaultEmptyString var name: String
    @DefaultEmptyString var imageURL: String
    @DefaultEmptyString var company: String
    let followers: Int?
    let following: Int?
    
    enum CodingKeys: String, CodingKey {
        
        case company, followers, following
        case name     = "login"
        case imageURL = "avatar_url"
    }
}
