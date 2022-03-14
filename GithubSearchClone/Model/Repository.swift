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

class Repository: Codable {
    
    let id: Int?
    let owner: Owner
    let starCount: Int?
    let license: License
    var name: String
    var language: String
    var introduce: String
    var visibility: String
    
    var isAddedStart: Bool = false
    
    enum CodingKeys: String, CodingKey {
        
        case id, name, owner, language, visibility, license
        case starCount = "stargazers_count"
        case introduce = "description"
    }
    
    init(from decoder: Decoder) throws {
    
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try? container.decode(Int.self, forKey: .id)
        self.owner = try container.decode(Owner.self, forKey: .owner)
        self.starCount = try? container.decode(Int.self, forKey: .starCount)
        self.license = try container.decode(License.self, forKey: .license)
        self.name = (try? container.decode(String.self, forKey: .name)) ?? ""
        self.language = (try? container.decode(String.self, forKey: .language)) ?? ""
        self.introduce = (try? container.decode(String.self, forKey: .introduce)) ?? ""
        self.visibility = (try? container.decode(String.self, forKey: .visibility)) ?? ""
    }
}

struct Owner: Codable {
    
    var name: String
    let id: Int?
    var imageURL: String
    
    enum CodingKeys: String, CodingKey {
        
        case name = "login"
        case id
        case imageURL = "avatar_url"
    }
    
    init(from decoder: Decoder) throws {
    
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = (try? container.decode(String.self, forKey: .name)) ?? ""
        self.id = try? container.decode(Int.self, forKey: .id)
        self.imageURL = (try? container.decode(String.self, forKey: .imageURL)) ?? ""
    }
}

struct License: Codable {
    
    var key: String
    var name: String
    var url: String
    
    init(from decoder: Decoder) throws {
    
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        
        self.name = (try? container?.decode(String.self, forKey: .name)) ?? ""
        self.key = (try? container?.decode(String.self, forKey: .key)) ?? ""
        self.url = (try? container?.decode(String.self, forKey: .url)) ?? ""
    }
}
