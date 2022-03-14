//
//  APIError.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/24.
//

import Foundation

enum APIError: Error {
    
    case invalidURL
    case invalidToken
    case accessDenied
    case failed(errCode: Int?, message: String?)
    case serverNotConnected
    
    var description: String {
        
        switch self {
            
            case .invalidToken:
                
                UserInfo.shared.checkAPIToken() // APIToken 초기화
                return ErrorMessage.requireLogin
            
            case .accessDenied:
            
                return ErrorMessage.notAllowedPage
                
            case .failed(_, _), .invalidURL:
                
                return ErrorMessage.defaultAPIFailed
                
            case .serverNotConnected:
                
                return ErrorMessage.defaultAPIServer
        }
    }
}

extension APIError {
    
    static func checkError(with statusCode: Int) -> APIError {
        
        
        if 500...599 ~= statusCode {
            
            return .serverNotConnected
        }
        
        if statusCode == 401 {
            
            return .invalidToken
        }
        
        if statusCode == 403 {
            
            return .accessDenied
        }
        
        return .failed(errCode: statusCode,
                       message: "")
        
    }
}
