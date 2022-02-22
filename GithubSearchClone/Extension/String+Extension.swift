//
//  String+Extension.swift
//  GithubSearchClone
//
//  Created by 박승태 on 2022/02/19.
//

import CryptoSwift

extension String {
    
    func aesEncrypt128() throws -> String {
        
        let DEFINE_KEY = "pstt0314pstt0314"
        let DEFINE_IV = "p0s3t1t4p0s3t1t4"
        
        do {
            
            let enc = try AES(key: DEFINE_KEY.bytes,
                              blockMode: CBC(iv: DEFINE_IV.bytes),
                              padding: .pkcs5).encrypt(self.bytes)
            let encData = NSData(bytes: enc, length: Int(enc.count))
            let base64String: String = encData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            return base64String
        }
        catch {
            
            print(error)
        }
        
        return ""
    }
    
    func aesDecrypt128() throws -> String {
        
        let DEFINE_KEY = "pstt0314pstt0314"
        let DEFINE_IV = "p0s3t1t4p0s3t1t4"
        
        do {
            
            let enc = try AES(key: DEFINE_KEY.bytes,
                              blockMode: CBC(iv: DEFINE_IV.bytes),
                              padding: .pkcs5)
            let datas = Data(base64Encoded: self)
            
            guard datas != nil else {
                
                return ""
            }
            
            let bytes = datas!.bytes
            let decode = try enc.decrypt(bytes)
            
            String(data: datas!, encoding: .utf8)
            
            return String(bytes: decode, encoding: .utf8) ?? ""
            
        }
        catch {
            
            print(error)                    
        }
        
        return ""
    }
}
