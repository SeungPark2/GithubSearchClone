//
//  Network.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/18.
//

import RxSwift
import RxCocoa

protocol NetworkProtocol {
    
    func requestGet(with endPoint: String,
                    query: [String: Any]?) -> Observable<Network.GetResponse>
    
    func requestBody(serverURL: String,
                     with endPoint: String,
                     params: [String: Any],
                     httpMethod: Network.HttpMethod) -> Observable<Data>
}

class Network: NetworkProtocol {
    
    static let shared: Network = Network()
    private init() { }
}

extension Network {
    
    // MARK: -- Public Method
    
    func requestGet(with endPoint: String,
                    query: [String : Any]?) -> Observable<GetResponse> {
        
        var urlString = Server.url + endPoint
        
        if let query = query {
            
            let queryArr = query.compactMap { key, value in "\(key)=\(value)" }
            let queryString = "?" + queryArr.joined(separator: "&")
            urlString += queryString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        }
        
        guard let url = URL(string: urlString) else {
            
            return .error(NetworkError.failed(errCode: nil,
                                              message: nil))
        }
        
        let request = self.createURLRequest(url: url,
                                            httpMethod: .get)
        
        return URLSession.shared.rx
                 .response(request: request)
                 .map { response, data -> GetResponse  in
                       
                     self.printRequestInfo(request.url?.description,
                                           request.httpMethod,
                                           query,
                                           data,
                                           response.statusCode)
                       
                     if 200...299 ~= response.statusCode {
                           
                         let linkString = response.allHeaderFields["Link"] as? String
                         
                         return GetResponse(isHadNextPage: linkString?.findNextPage() ?? false,
                                            data: data)
                     }
                    
                     throw self.checkNetworkError(with: response.statusCode)
                 }
    }
    
    func requestBody(serverURL: String = Server.url,
                     with endPoint: String,
                     params: [String : Any],
                     httpMethod: HttpMethod) -> Observable<Data> {
        
        guard let url = URL(string: serverURL + endPoint) else {
            
            return .error(NetworkError.failed(errCode: nil,
                                              message: nil))
        }
        
        var request = self.createURLRequest(url: url,
                                            httpMethod: httpMethod)
        
        do {
            
            request.httpBody = try JSONSerialization.data(withJSONObject: params as [String: Any],
                                                          options: .prettyPrinted)
        }
        catch {
            
            print(error.localizedDescription)
            return .error(error)
        }
        
        return URLSession.shared.rx
                 .response(request: request)
                 .map { response, data -> Data  in
                        
                     self.printRequestInfo(request.url?.description,
                                           request.httpMethod,
                                           params,
                                           data,
                                           response.statusCode)
                        
                     if 200...299 ~= response.statusCode {
                            
                         return data
                     }
                     
                     throw self.checkNetworkError(with: response.statusCode)
                 }
    }
    
    // MARK: -- Private Method
    
    private func createURLRequest(url: URL,
                                  httpMethod: HttpMethod) -> URLRequest {
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        
        request.setValue("application/vnd.github.v3+json",
                         forHTTPHeaderField: "Accept")
        request.setValue("application/json;charset=UTF-8",
                         forHTTPHeaderField: "Content-Type")
        
        if UserInfo.shared.apiToken != "" {
            
            request.setValue("Bearer \(UserInfo.shared.apiToken)",
                             forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
}

extension Network {
    
    // MARK: -- Log
    
    static func printRequestInfo(_ url: String?,
                                  _ method: String?,
                                  _ params: [String: Any]?,
                                  _ data: Data,
                                  _ statusCode: Int) {
        
        var message: String = "\n\n"
        message += "/*————————————————-————————————————-————————————————-"
        message += "\n|                    HTTP REQUEST                    |"
        message += "\n—————————————————————————————————-————————————————---*/"
        message += "\n"
        message += "* METHOD : \(method ?? "")"
        message += "\n"
        message += "* URL : \(url ?? "")"
        message += "\n"
        message += "* PARAM : \(params?.description ?? "")"
        message += "\n"
        message += "* STATUS CODE : \(statusCode)"
        message += "\n"
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
            
            message += "* RESPONSE : \n\(json)"
        }
        else {
            
            message += "* RESPONSE : \n\(data.description)"
        }
        message += "\n"
        message += "/*————————————————-————————————————-————————————————-"
        message += "\n|                    RESPONSE END                     |"
        message += "\n—————————————————————————————————-————————————————---*/"
        println(message)
    }
    
    // MARK: - Log
    private func println<T>(_ object: T,
                            _ file: String = #file,
                            _ function: String = #function, _ line: Int = #line){
#if DEBUG
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss:SSS"
        let process = ProcessInfo.processInfo
        
        var tid:UInt64 = 0;
        pthread_threadid_np(nil, &tid);
        let threadId = tid
        
        Swift.print("\(dateFormatter.string(from: NSDate() as Date)) \(process.processName))[\(process.processIdentifier):\(threadId)] \((file as NSString).lastPathComponent)(\(line)) \(function):\t\(object)")
#else
#endif
    }
}
