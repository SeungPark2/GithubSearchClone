//
//  RepositoryListService.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/03/08.
//

import RxSwift
import RxCocoa
import Foundation

protocol RepositoryListServiceProtocol {
    
    var repoNextPage: Int? { get }
    var fullNameNextPage: Int? { get }
    
    func requestFullName(with searchWord: String) -> Observable<[FullName]>
    func requestRepo(with searchWord: String) -> Observable<[Repository]>
    
    func requestChangeStar(with repo: Repository) -> Observable<Bool>
}

class RepositoryListService: RepositoryListServiceProtocol {
    
    var apiToken: String? = nil
    
    var repoNextPage: Int? = 1
    var fullNameNextPage: Int? = 1
    
    func requestFullName(with searchWord: String) -> Observable<[FullName]> {
        
        let urlString = Server.url +
                        Root.search +
                        EndPoint.repositories +
                        "?q=\(searchWord)" +
                        "&per_page=20" +
                        "&page=\(self.fullNameNextPage ?? 1)"
        
        guard let url = URL(string: urlString) else {
            
            return .error(APIError.invalidURL)
        }
        
        let request = APIRequest(method: .get,
                                 url: url).create(with: self.apiToken)
     
        return URLSession.shared.rx
                .response(request: request)
                .map { response, data -> Data in
                    
                    if 200...299 ~= response.statusCode {
                        
                        if let linkString = response.allHeaderFields["Link"] as? String,
                           linkString.findNextPage() {
                            
                            self.fullNameNextPage = (self.fullNameNextPage ?? 1) + 1
                        }
                        else {
                            
                            self.fullNameNextPage = nil
                        }
                        
                        return data
                    }
                    
                    throw APIError.checkError(with: response.statusCode)
                }
                .decode(type: RepositoryFullNames.self, decoder: JSONDecoder())
                .map { $0.items }
    }
    
    func requestRepo(with searchWord: String) -> Observable<[Repository]> {
        
        let urlString = Server.url +
                        Root.search +
                        EndPoint.repositories +
                        "?q=\(searchWord)" +
                        "&per_page=20" +
                        "&page=\(self.repoNextPage ?? 1)"
        
        guard let url = URL(string: urlString) else {
            
            return .error(APIError.invalidURL)
        }
        
        let request = APIRequest(method: .get,
                                 url: url).create(with: self.apiToken)
     
        return URLSession.shared.rx
                .response(request: request)
                .map { response, data -> Data in
                    
                    if 200...299 ~= response.statusCode {
                        
                        if let linkString = response.allHeaderFields["Link"] as? String,
                           linkString.findNextPage() {
                            
                            self.repoNextPage = (self.repoNextPage ?? 1) + 1
                        }
                        else {
                            
                            self.repoNextPage = nil
                        }
                        
                        return data
                    }
                    
                    throw APIError.checkError(with: response.statusCode)
                }
                .decode(type: Repositories.self, decoder: JSONDecoder())
                .map { $0.items }
    }
    
    func requestChangeStar(with repo: Repository) -> Observable<Bool> {
        
        let urlString = Server.url +
                        Root.user +
                        EndPoint.startList +
                        "/\(repo.owner.name)/" +
                        "\(repo.name)"
        
        guard let url = URL(string: urlString) else {
            
            return .error(APIError.invalidURL)
        }
        
        let request = APIRequest(method: repo.isAddedStart ? .delete : .put,
                                 url: url).create(with: self.apiToken)
     
        return URLSession.shared.rx
                .response(request: request)
                .map { response, data -> Bool in
                    
                    if 200...299 ~= response.statusCode {
                        
                        return true
                    }
                    
                    throw APIError.checkError(with: response.statusCode)
                }
    }
}
