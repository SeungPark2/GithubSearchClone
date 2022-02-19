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
                    query: [String: Any]?) -> Observable<Data>
    
    func requestPost(with endPoint: String,
                     params: [String: Any]) -> Observable<Data>
}

class Network: NetworkProtocol {
    
    static let shared: Network = Network()
    private init() { }
    
    enum HttpMethod: String {
        
        case get    = "GET"
        case post   = "POST"
        case put    = "PUT"
        case delete = "DELETE"
    }
    
    enum NetworkError: Error {
        
        case invalidToken
        case failed(errCode: Int?, message: String?)
        case serverNotConnected
    }
}

extension Network {
    
    func requestGet(with endPoint: String,
                    query: [String : Any]?) -> Observable<Data> {
        
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
        
        return self.requestDataTask(request: request,
                                    params: query)
    }
    
    func requestPost(with endPoint: String,
                     params: [String : Any]) -> Observable<Data> {
        
        guard let url = URL(string: Server.url + endPoint) else {
            
            return .error(NetworkError.failed(errCode: nil,
                                              message: nil))
        }
        
        var request = self.createURLRequest(url: url,
                                            httpMethod: .post)
        
        do {
            
            request.httpBody = try JSONSerialization.data(withJSONObject: params as [String: Any],
                                                          options: .prettyPrinted)
        }
        catch {
            
            print(error.localizedDescription)
            return .error(error)
        }
        
        return self.requestDataTask(request: request,
                                    params: params)
    }
    
    private func createURLRequest(url: URL,
                                  httpMethod: HttpMethod) -> URLRequest {
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        
        request.setValue("application/vnd.github.v3+json",
                         forHTTPHeaderField: "Accept")
        request.setValue("application/json;charset=UTF-8",
                         forHTTPHeaderField: "Content-Type")
        
        if let apiToken = UserInfo.shared.apiToken {
            
            request.setValue("access_token \(apiToken)",
                             forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    private func requestDataTask(request: URLRequest,
                                 params: [String: Any]?) -> Observable<Data> {
        
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
                
                
                if 500...599 ~= response.statusCode {
                    
                    throw NetworkError.serverNotConnected
                }
                
                if response.statusCode == 401 {
                    
                    throw NetworkError.invalidToken
                }
                
                throw NetworkError.failed(errCode: response.statusCode,
                                          message: "")
            }
    }
}

extension Network.NetworkError {
    
    var description: String {
        
        switch self {
            
            case .invalidToken:
                
                return "로그인 후 시도해주세요."
                
            case .failed(_, _):
                
                return "예기치 못한 오류가 발생했습니다. \n잠시 후 다시 시도해주세요."
                
            case .serverNotConnected:
                
                return "일시적으로 이용이 불가능합니다. \n잠시 후 다시 시도해주세요."
        }
    }
}

extension Network {
    
    private func printRequestInfo(_ url: String?, _ method: String?, _ params: [String: Any]?, _ data: Data, _ statusCode: Int) {
        
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
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            
            message += "* RESPONSE : \n\(json.description)"
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
