//
//  UserInfo.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/18.
//

import UIKit

class UserInfo {
    
    static let shared: UserInfo = UserInfo()
    private init() { }
    
    private var _apiToken: String? = nil 
    
    var apiToken: String? {
        get { return try? self._apiToken?.aesDecrypt128() }
        set { self._apiToken = newValue }
    }
    
    var code: String = ""
    
    func requestGithubCode() {
        
        let scope = "repo,user"
        
        let urlString = Server.github +
                        Root.login +
                        Root.oauth +
                        EndPoint.authorize + "?client_id=\("")&scope=\(scope)"
        
        if let url = URL(string: urlString),
           UIApplication.shared.canOpenURL(url) {
            
            UIApplication.shared.open(url)
        }
    }
    
    func requestAPIToken(code: String) {
        
        guard let url = URL(string: Server.github +
                                    Root.login +
                                    Root.oauth +
                                    EndPoint.access_token) else {
            
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
            
            print(error.localizedDescription)
        }
                
        URLSession.shared.dataTask(with: request) {
            
            data, response, error in
            
            guard let data = data else {
                
                print(error?.localizedDescription)
                return
            }
            
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
            print("statusCode \((response as? HTTPURLResponse)?.statusCode)")
            print("json \(json ?? [:])")
            
            self._apiToken = try? ((json?["accss_token"] as? String) ?? "").aesEncrypt128()
            
        }.resume()
        
    }
}
