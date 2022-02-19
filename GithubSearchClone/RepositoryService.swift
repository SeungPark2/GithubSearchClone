//
//  RepositoryService.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/18.
//

import RxSwift

class RepositoryService {
    
    func requestRepository(with searchWord: String) -> Observable<Repository> {
        
        return Network.shared.requestGet(with: EndPoint.search,
                                         query: ["q": searchWord])
                .decode(type: Repository.self, decoder: JSONDecoder())
    }
}
