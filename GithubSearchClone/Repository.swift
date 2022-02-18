//
//  Repository.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/18.
//

import Foundation

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
    
//    func languageColor() -> String {
//
//        switch self.language {
//
//            case "Swift":        return "Orange"
//            case "Objective-C":  return "Blue"
//            case "C":            return "Blue"
//            case "C++":          return "Pink"
//            case "C#":           return "Green"
//            case "Python":       return "Blue"
//            case "JavaScript":   return "Yellow"
//            case "Java":         return "Blue"
//            case "HTML":         return "Blue"
//            case "Ruby":         return "Red"
//            case "Shell":        return "Blue"
//
//        default: ""
//        }
//    }
}

struct Owner: Codable {
    
    @DefaultEmptyString var name: String
    let id: Int?
}

struct License: Codable {
    
    @DefaultEmptyString var key: String
    @DefaultEmptyString var name: String
    @DefaultEmptyString var url: String
}
