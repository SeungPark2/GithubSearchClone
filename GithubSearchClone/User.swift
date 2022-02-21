//
//  User.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/20.
//

import Foundation

struct User: Codable {
    
    var name: String
    var imageURL: String
    var company: String
    let followers: Int
    let following: Int
    
    enum CodingKeys: String, CodingKey {
        
        case company, followers, following
        case name     = "login"
        case imageURL = "avatar_url"
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = (try? container.decode(String.self, forKey: .name)) ?? ""
        self.imageURL = (try? container.decode(String.self, forKey: .imageURL)) ?? ""
        self.company = (try? container.decode(String.self, forKey: .company)) ?? ""
        self.followers = (try? container.decode(Int.self, forKey: .followers)) ?? 0
        self.following = (try? container.decode(Int.self, forKey: .following)) ?? 0
    }
}
