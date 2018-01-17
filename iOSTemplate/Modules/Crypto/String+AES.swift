//
//  String+AES.swift
//  iOSTemplate
//
//  Copyright © 2018 Cabot Technology Solutions Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation
import CryptoSwift

extension String {
    
    //MARK:- Encrypt/Decrypt
    func aesEncrypt(key: String, iv: String) throws -> String {
        let data = self.data(using: .utf8)!
        let encrypted = try! AES(key: key, iv: iv, blockMode: .CBC, padding: .pkcs7).encrypt([UInt8](data))
        let encryptedData = Data(encrypted)

        return encryptedData.base64EncodedString()
    }
    
    func aesDecrypt(key: String, iv: String) throws -> String {
        let data = Data(base64Encoded: self)!
        let decrypted = try! AES(key: key, iv: iv, blockMode: .CBC, padding: .pkcs7).decrypt([UInt8](data))
        let decryptedData = Data(decrypted)

        return String(bytes: decryptedData.bytes, encoding: .utf8) ?? "Could not decrypt"
    }
    
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
