//
//  Utilities.swift
//  iOSTemplate
//
//  Copyright © 2018 Cabot Technology Solutions Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import UIKit

class Utilities: NSObject {
    
    //Generate AES Keys and and Store them in Keychain
    class func generateAPIKeys()  {
        // Generate the AES Symetric key and the Initialization Vector if not available.
        KeychainService.deletePassword(service: AES_KEY)
        KeychainService.deletePassword(service: AES_IV)
        
        let aesKey = AsymmetricCryptoManager.sharedInstance.randomStringWithLength(len: 32) as String // length == 32
        print("AES Key Generated: \(aesKey)")
        let iv = String(aesKey.characters.dropLast(16))
        print("AES IV: \(iv)")
        
        // Save the key and vector in the iOS Keychain
        KeychainService.savePassword(service: AES_KEY, data: aesKey as NSString)
        KeychainService.savePassword(service: AES_IV, data: iv as NSString)
    }


    //MARK:- Encrypt/Decrypt
    class func encrypt(_ message: String) -> String {
        
        guard let aesKey = KeychainService.loadPassword(service: AES_KEY), let aesIV = KeychainService.loadPassword(service: AES_IV) else {
            //MARK:- TODO - Handle Failure
            return "ERROR: Invalid Keys in Keychain!"
        }
        
        return try! message.aesEncrypt(key: aesKey as String, iv: aesIV as String)
    }
    
    class func decrypt(_ message: String) -> String {
        
        guard let aesKey = KeychainService.loadPassword(service: AES_KEY), let aesIV = KeychainService.loadPassword(service: AES_IV) else {
            //MARK:- TODO - Handle Error
            return "ERROR: Invalid Keys in Keychain!"
        }
        
        return try! message.aesDecrypt(key: aesKey as String, iv: aesIV as String)
    }
    
    //MARK:- Validation Methods
    class func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}
