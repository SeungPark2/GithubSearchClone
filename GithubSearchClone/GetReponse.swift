//
//  GetReponse.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/24.
//

import Foundation

extension Network {
    
    struct GetResponse {
        
        let isHadNextPage: Bool
        let data: Data
    }

}
