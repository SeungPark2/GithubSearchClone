//
//  RepositoryFullNames.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/18.
//

import Foundation

struct RepositoryFullNames: Codable {
    
    let totalCount: Int?
    let fullNames: [FullName]
    
    enum CodingKeys: String, CodingKey {
        
        case totalCount = "total_count"
        case fullNames = "items"
    }
}

struct FullName: Codable {
    
    @DefaultEmptyString var fullName: String
    
    enum CodingKeys: String, CodingKey {
        
        case fullName = "full_name"
    }
}
