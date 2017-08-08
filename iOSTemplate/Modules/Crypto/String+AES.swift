//
//  String+AES.swift
//  SocialPay
//
//  Created by Shibin Moideen on 4/3/17.
//  Copyright © 2017 cabot. All rights reserved.
//

import Foundation
import CryptoSwift

extension String {
    
    //MARK:- Encrypt/Decrypt
//    func aesEncrypt(key: String, iv: String) throws -> String {
//        let data = self.data(using: .utf8)!
//        let encrypted = try! AES(key: key, iv: iv, blockMode: .CBC, padding: PKCS7()).encrypt([UInt8](data))
//        let encryptedData = Data(encrypted)
//
//        return encryptedData.base64EncodedString()
//    }
//    
//    func aesDecrypt(key: String, iv: String) throws -> String {
//        let data = Data(base64Encoded: self)!
//        let decrypted = try! AES(key: key, iv: iv, blockMode: .CBC, padding: PKCS7()).decrypt([UInt8](data))
//        let decryptedData = Data(decrypted)
//
//        return String(bytes: decryptedData.bytes, encoding: .utf8) ?? "Could not decrypt"
//    }
    
    //MARK:- Encode/Decode - Base64
    func base64Encoded() -> String {
        let data = (self).data(using: String.Encoding.utf8)
        let base64String = data!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))

        return base64String
    }
    
    func base64Decoded() -> String {
        let decodedData = Data(base64Encoded: self)!
        let decodedString = String(data: decodedData, encoding: .utf8)!

        return String(decodedString)
    }
    
    //MARK:- Encode/Decode - Url
    func encodeUrl() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
    }
    
    func decodeUrl() -> String {
        return self.removingPercentEncoding!
    }
}
