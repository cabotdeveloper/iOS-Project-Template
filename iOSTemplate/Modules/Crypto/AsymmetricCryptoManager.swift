//
//  AsymmetricCryptoManager.swift
//  AsymmetricCrypto
//
//  Created by Ignacio Nieto Carvajal on 4/10/15.
//  Copyright © 2015 Ignacio Nieto Carvajal. All rights reserved.
//
import UIKit

// Singleton instance
private let _singletonInstance = AsymmetricCryptoManager()

// Constants
private let kAsymmetricCryptoManagerApplicationTag = "com.AsymmetricCrypto.keypair"
private let kAsymmetricCryptoManagerKeyType = kSecAttrKeyTypeRSA
private let kAsymmetricCryptoManagerKeySize = 2048
private let kPasswordLessManagerCypheredBufferSize = 1024
private let kAsymmetricCryptoManagerSecPadding: SecPadding = .PKCS1
var responsePublicKey: SecKey?
var responsePrivateKey: SecKey?

enum PasswordLessException: Error {
    case unknownError
    case duplicateFoundWhileTryingToCreateKey
    case keyNotFound
    case authFailed
    case unableToAddPublicKeyToKeyChain
    case wrongInputDataFormat
    case unableToEncrypt
    case unableToDecrypt
    case unableToSignData
    case unableToVerifySignedData
    case unableToPerformHashOfData
    case unableToGenerateAccessControlWithGivenSecurity
    case outOfMemory
}

class AsymmetricCryptoManager: NSObject {
    
    /** Shared instance */
    class var sharedInstance: AsymmetricCryptoManager {
        return _singletonInstance
    }
    
    
    func randomStringWithLength (len : Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for i in 0..<len {
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
        }
        
        return randomString
    }
    
    func generateKeyPair() -> OSStatus{
        
        //Generation of RSA private and public keys
        let parameters: [String: AnyObject] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: 1024 as AnyObject
        ]
        
        return SecKeyGeneratePair(parameters as CFDictionary, &responsePublicKey, &responsePrivateKey)
    }
    
    // MARK: - Manage keys
    func createSecureKeyPair(completion: ((_ success: Bool, _ error: PasswordLessException?) -> Void)? = nil) {
        // access control for the private key
        var flags: SecAccessControlCreateFlags = [SecAccessControlCreateFlags.userPresence, SecAccessControlCreateFlags.userPresence]
        
        if #available(iOS 9.0, *) {
            flags = [SecAccessControlCreateFlags.touchIDAny, SecAccessControlCreateFlags.privateKeyUsage]
        } else {
            // Fallback
        }
        guard let accessControl = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, flags, nil) else {
            completion?(false, .unableToGenerateAccessControlWithGivenSecurity)
            return
        }
        
        // private key parameters
        let privateKeyParams: [String: AnyObject] = [
            kSecAttrAccessControl as String: accessControl,
            kSecAttrIsPermanent as String: true as AnyObject,
            kSecAttrApplicationTag as String: kAsymmetricCryptoManagerApplicationTag as AnyObject,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: 1024 as AnyObject
        ]
        
        // private key parameters
        let publicKeyParams: [String: AnyObject] = [
            kSecAttrIsPermanent as String: true as AnyObject,
            kSecAttrApplicationTag as String: kAsymmetricCryptoManagerApplicationTag as AnyObject,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: 1024 as AnyObject
        ]
        
        // global parameters for our key generation
        let parameters: [String: AnyObject] = [
            kSecAttrKeyType as String:          kAsymmetricCryptoManagerKeyType,
            kSecAttrKeySizeInBits as String:    kAsymmetricCryptoManagerKeySize as AnyObject,
            kSecPublicKeyAttrs as String:       publicKeyParams as AnyObject,
            kSecPrivateKeyAttrs as String:      privateKeyParams as AnyObject,
            ]
        
        // asynchronously generate the key pair and call the completion block
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { () -> Void in
            //            var pubKey, privKey: SecKeyRef?
            let status = SecKeyGeneratePair(parameters as CFDictionary, &responsePublicKey, &responsePrivateKey)
            
            if status == errSecSuccess {
                DispatchQueue.main.async(execute: { completion?(true, nil) })
            } else {
                var error = PasswordLessException.unknownError
                switch (status) {
                case errSecDuplicateItem: error = .duplicateFoundWhileTryingToCreateKey
                case errSecItemNotFound: error = .keyNotFound
                case errSecAuthFailed: error = .authFailed
                default: break
                }
                DispatchQueue.main.async(execute: { completion?(false, error) })
            }
        }
    }
    
    func getResponsePrivateKey() -> SecKey? {
        return responsePrivateKey!
    }
    
    func getResponsePublicKey() -> SecKey? {
        return responsePublicKey!
    }
    
    func getPublicKeyData() -> NSData? {
        let parameters = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrApplicationTag as String: kAsymmetricCryptoManagerApplicationTag,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecReturnData as String: true
        ] as [String : Any]
        var data: AnyObject?
        let status = SecItemCopyMatching(parameters as CFDictionary, &data)
        if status == errSecSuccess {
            return data as? NSData
        } else { return nil }
    }
    
    private func getPublicKeyReference() -> SecKey? {
        let parameters = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrApplicationTag as String: kAsymmetricCryptoManagerApplicationTag,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecReturnRef as String: true,
            ] as [String : Any]
        var ref: AnyObject?
        let status = SecItemCopyMatching(parameters as CFDictionary, &ref)
        if status == errSecSuccess { return ref as! SecKey? } else { return nil }
    }
    
    private func getPrivateKeyReference() -> SecKey? {
        let parameters = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrApplicationTag as String: kAsymmetricCryptoManagerApplicationTag,
            kSecReturnRef as String: true,
            ] as [String : Any]
        var ref: AnyObject?
        let status = SecItemCopyMatching(parameters as CFDictionary, &ref)
        if status == errSecSuccess { return ref as! SecKey? } else { return nil }
    }
    
    func keyPairExists() -> Bool {
        return self.getPublicKeyData() != nil
    }
    
    func deleteSecureKeyPair(completion: ((_ success: Bool) -> Void)?) {
        // private query dictionary
        let deleteQuery = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: kAsymmetricCryptoManagerApplicationTag,
            ] as [String : Any]
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { () -> Void in
            let status = SecItemDelete(deleteQuery as CFDictionary) // delete private key
            DispatchQueue.main.async(execute: { completion?(status == errSecSuccess) })        }
    }
    
    // MARK: - Cypher and decypher methods
    
    func encryptMessageWithPublicKey(message: String, publicKeyRef: SecKey, completion: @escaping (_ success: Bool, _ data: Data?, _ error: PasswordLessException?) -> Void) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { () -> Void in
            
            let publicKey = publicKeyRef
            // prepare input input plain text
            guard let messageData = message.data(using: String.Encoding.utf8) else {
                completion(false, nil, .wrongInputDataFormat)
                return
            }
            let plainText = UnsafePointer<UInt8>(messageData.bytes)
            let plainTextLen = messageData.count
            
            // prepare output data buffer
            var cipherData = Data(count: SecKeyGetBlockSize(publicKeyRef))
            let cipherText = cipherData.withUnsafeMutableBytes({ (bytes: UnsafeMutablePointer<UInt8>) -> UnsafeMutablePointer<UInt8> in
                return bytes
            })
            var cipherTextLen = cipherData.count
            
            let status = SecKeyEncrypt(publicKey, .PKCS1, plainText, plainTextLen, cipherText, &cipherTextLen)
            
            // analyze results and call the completion in main thread
            DispatchQueue.main.async(execute: { () -> Void in
                completion(status == errSecSuccess, cipherData, status == errSecSuccess ? nil : .unableToEncrypt)
                cipherText.deinitialize()
            })
            
            return
        }
    }
    
    func decryptMessageWithPrivateKey(_ encryptedData: Data, completion: @escaping (_ success: Bool, _ result: String?, _ error: PasswordLessException?) -> Void) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { () -> Void in
            
            if let privateKeyRef = self.getPrivateKeyReference() {
                // prepare input input plain text
                let encryptedText = (encryptedData as NSData).bytes.bindMemory(to: UInt8.self, capacity: encryptedData.count)
                let encryptedTextLen = encryptedData.count
                
                // prepare output data buffer
                var plainData = Data(count: kPasswordLessManagerCypheredBufferSize)
                let plainText = plainData.withUnsafeMutableBytes({ (bytes: UnsafeMutablePointer<UInt8>) -> UnsafeMutablePointer<UInt8> in
                    return bytes
                })
                var plainTextLen = plainData.count
                
                let status = SecKeyDecrypt(privateKeyRef, .PKCS1, encryptedText, encryptedTextLen, plainText, &plainTextLen)
                
                // analyze results and call the completion in main thread
                DispatchQueue.main.async(execute: { () -> Void in
                    if status == errSecSuccess {
                        // adjust NSData length
                        plainData.count = plainTextLen
                        // Generate and return result string
                        if let string = NSString(data: plainData as Data, encoding: String.Encoding.utf8.rawValue) as String? {
                            completion(true, string, nil)
                        }
                        else {
                            completion(false, nil, .unableToDecrypt)
                        }
                    }
                    else {
                        completion(false, nil, .unableToDecrypt)
                    }
                    plainText.deinitialize()
                })
                return
            } else { DispatchQueue.main.async(execute: { completion(false, nil, .keyNotFound) }) }
        }
    }
    
    // MARK: - Sign and verify signature.
    /*
     func signMessageWithPrivateKey(message: String, completion: (success: Bool, data: NSData?, error: PasswordLessException?) -> Void) {
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
     var error: PasswordLessException? = nil
     
     if let privateKeyRef = self.getPrivateKeyReference() {
     // result data
     guard let resultData = NSMutableData(length: SecKeyGetBlockSize(privateKeyRef)) else {
     dispatch_async(dispatch_get_main_queue(), { completion(success: false, data: nil, error: .OutOfMemory) })
     return
     }
     let resultPointer    = UnsafeMutablePointer<UInt8>(resultData.mutableBytes)
     var resultLength     = resultData.length
     
     if let plainData = message.dataUsingEncoding(NSUTF8StringEncoding) {
     // generate hash of the plain data to sign
     guard let hashData = NSMutableData(length: Int(CC_SHA1_DIGEST_LENGTH)) else {
     dispatch_async(dispatch_get_main_queue(), { completion(success: false, data: nil, error: .OutOfMemory) })
     return
     }
     let hash = UnsafeMutablePointer<UInt8>(hashData.mutableBytes)
     CC_SHA1(UnsafePointer<Void>(plainData.bytes), CC_LONG(plainData.length), hash)
     
     // sign the hash
     let status = SecKeyRawSign(privateKeyRef, SecPadding.PKCS1SHA1, hash, hashData.length, resultPointer, &resultLength)
     if status != errSecSuccess { error = .UnableToEncrypt }
     else { resultData.length = resultLength }
     hash.destroy()
     } else { error = .WrongInputDataFormat }
     
     // analyze results and call the completion in main thread
     dispatch_async(dispatch_get_main_queue(), { () -> Void in
     if error == nil {
     // adjust NSData length and return result.
     resultData.length = resultLength
     completion(success: true, data: resultData, error: nil)
     } else { completion(success: false, data: nil, error: error) }
     //resultPointer.destroy()
     })
     } else { dispatch_async(dispatch_get_main_queue(), { completion(success: false, data: nil, error: .KeyNotFound) }) }
     }
     }
     */
    
    /*
     func verifySignaturePublicKey(data: NSData, signatureData: NSData, completion: (success: Bool, error: PasswordLessException?) -> Void) {
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
     var error: PasswordLessException? = nil
     
     if let publicKeyRef = self.getPublicKeyReference() {
     // hash data
     guard let hashData = NSMutableData(length: Int(CC_SHA1_DIGEST_LENGTH)) else {
     dispatch_async(dispatch_get_main_queue(), { completion(success: false, error: .OutOfMemory) })
     return
     }
     let hash = UnsafeMutablePointer<UInt8>(hashData.mutableBytes)
     CC_SHA1(UnsafePointer<Void>(data.bytes), CC_LONG(data.length), hash)
     // input and output data
     let signaturePointer = UnsafePointer<UInt8>(signatureData.bytes)
     let signatureLength = signatureData.length
     
     let status = SecKeyRawVerify(publicKeyRef, SecPadding.PKCS1SHA1, hash, Int(CC_SHA1_DIGEST_LENGTH), signaturePointer, signatureLength)
     
     if status != errSecSuccess { error = .UnableToDecrypt }
     
     // analyze results and call the completion in main thread
     hash.destroy()
     dispatch_async(dispatch_get_main_queue(), { () -> Void in
     completion(success: status == errSecSuccess, error: error)
     })
     return
     } else { dispatch_async(dispatch_get_main_queue(), { completion(success: false, error: .KeyNotFound) }) }
     }
     }
     */
}

