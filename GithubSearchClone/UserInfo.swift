//
//  UserInfo.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/18.
//

import Foundation

class UserInfo {
    
    static let shared: UserInfo = UserInfo()
    private init() { }
    
    private var _apiToken: String? = nil
    
    var apiToken: String? {
        get { return self._apiToken }
        set { self._apiToken = newValue }
    }
}
