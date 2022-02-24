//
//  NetworkError.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/24.
//

import Foundation

enum NetworkError: Error {
    
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
                
            case .failed(_, _):
                
                return ErrorMessage.defaultAPIFailed
                
            case .serverNotConnected:
                
                return ErrorMessage.defaultAPIServer
        }
    }
}
