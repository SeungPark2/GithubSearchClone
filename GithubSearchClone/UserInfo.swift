//
//  UserInfo.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/18.
//

import UIKit

class UserInfo {
    
    static let shared: UserInfo = UserInfo()
    private init() {
        
        self._apiToken = UserDefaults.standard.string(forKey: self.apiTokenKey)
    }
    
    var apiToken: String {
        
        get { return self._apiToken ?? "" }
    }
    
    func checkAPIToken() {
        
        if self.apiToken == "" {
            
            self.requestGithubCode()
            return
        }
        
        self.logout()
        UIApplication.topViewController()?.viewWillAppear(true)
    }
    
    func requestAPIToken(code: String) {
        
        guard let url = URL(string: Server.github +
                                    Root.login +
                                    Root.oauth +
                                    EndPoint.accessToken) else {
            
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
            
            [weak self] data, response, error in
            
            guard let data = data else {
                
                print(error?.localizedDescription)
                return
            }
            
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            
            print("statusCode \((response as? HTTPURLResponse)?.statusCode)")
            print("json \(json ?? [:])")
            
            self?._apiToken = (json?["access_token"] as? String) ?? ""
            UserDefaults.standard.setValue(self?._apiToken,
                                           forKey: self?.apiTokenKey ?? "")
            
            DispatchQueue.main.async {
            
                let vc = UIApplication.topViewController()
                
                vc?.viewWillAppear(true)
            }
            
        }.resume()
    }
    
    private func logout() {
        
        self._apiToken = nil
        UserDefaults.standard.setValue(nil,
                                       forKey: self.apiTokenKey)
    }
    
    private func requestGithubCode() {
        
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
    
    private var _apiToken: String? = nil
    private let apiTokenKey: String = "apiTokenKey"
}
