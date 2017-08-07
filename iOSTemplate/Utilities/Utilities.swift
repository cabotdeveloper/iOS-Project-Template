//
//  Utilities.swift
//  iOSTemplate
//
//  Created by Shibin Moideen on 6/12/17.
//  Copyright © 2017 Shibin Moideen. All rights reserved.
//

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


    // Encrypt the string using AES Encrypt
    class func encrypt(_ message: String) -> String {
        
        guard let aesKey = KeychainService.loadPassword(service: AES_KEY), let aesIV = KeychainService.loadPassword(service: AES_IV) else {
            //MARK:- TODO - Handle Failure
            return "ERROR: Invalid Keys in Keychain!"
        }
        
        return try! message.aesEncrypt(key: aesKey as String, iv: aesIV as String)
    }
    
    // Decrypt the decoded string using AES Decrypt
    class func decrypt(_ message: String) -> String {
        
        guard let aesKey = KeychainService.loadPassword(service: AES_KEY), let aesIV = KeychainService.loadPassword(service: AES_IV) else {
            //MARK:- TODO - Handle Error
            return "ERROR: Invalid Keys in Keychain!"
        }
        
        return try! message.aesDecrypt(key: aesKey as String, iv: aesIV as String)
    }
}
