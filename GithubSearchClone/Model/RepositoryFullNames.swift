//
//  RepositoryFullNames.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/18.
//

import Foundation

struct RepositoryFullNames: Codable {
    
    let totalCount: Int?
    let items: [FullName]
    
    enum CodingKeys: String, CodingKey {
        
        case totalCount = "total_count"
        case items
    }
}

struct FullName: Codable {
    
    var fullName: String
    
    enum CodingKeys: String, CodingKey {
        
        case fullName = "full_name"
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.fullName = (try? container.decode(String.self, forKey: .fullName)) ?? ""
    }
}
