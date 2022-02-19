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
    
    var code: String = ""
    
    // Image Site: https://icons8.com/icons
    
    func requestGithubCode() {
        
        
    }
    
    func requestAPIToken(code: String) {
        
        guard let url = URL(string: "https://github.com/login/oauth/access_token") else {
            
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        request.allHTTPHeaderFields?.updateValue("application/json",
                                                 forKey: "Content-Type")
        
        request.allHTTPHeaderFields?.updateValue("application/vnd.github.v3+json",
                                                 forKey: "Accept")
        
        let param = ["client_id": "",
                     "client_secret": "",
                     "code": code]
        
        do {
            
            try request.httpBody = JSONSerialization.data(withJSONObject: param,
                                                          options: [])
        }
        catch {
            
            print("err \(error.localizedDescription)")
        }
                
        URLSession.shared.dataTask(with: request) {
            
            data, response, error in
            
            guard let data = data else {
                
                print("!!! \(error?.localizedDescription ?? "")")
                return
            }
            
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
            print("json \(json ?? [:])")
            
            self._apiToken = (json?["accss_token"] as? String) ?? ""
            
        }.resume()
        
    }
}
