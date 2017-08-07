//
//  APIController.swift
//  iOSTemplate
//
//  Created by Shibin Moideen on 6/12/17.
//  Copyright © 2017 Shibin Moideen. All rights reserved.
//

import UIKit

class APIController: NSObject {

    // This class will list all the API functions need to be implemented in the application.
    // All API calls should go through this class
    // Common features like parsing the response will be implemented here.
    var sessionAvailable : URLSession!
    
    override init() {
        //print("hello")
        if sessionAvailable == nil {
            sessionAvailable = URLSession.shared
        }
    }
    
    func createAndStoreAesKey() {
        
    }
    
    func initializeApp(dict: NSDictionary, withApi api: String, callBack:(_ responseDict: NSDictionary?, _ error: NSError?) -> ()) {
        
            print("====INITIALIZE API==== \(api)")
            print("DICT: \(dict)")
            var jsonError : NSError?
            var postBody: NSData?
            var jsonString : String?
            
            if dict.allKeys.count > 0 {
                do {
                    postBody = try JSONSerialization.data(withJSONObject: dict, options:JSONSerialization.WritingOptions.prettyPrinted) as NSData
                    jsonString = String.init(data: postBody! as Data, encoding: String.Encoding.utf8)
                    
                    if jsonString != nil {
                        print(jsonString as Any)
                        let encryptedJson = Utilities.encrypt(jsonString!)
                        let reqDict = NSDictionary.init(object: encryptedJson, forKey: ENCRYPTED_DATA as NSCopying)
                        print(reqDict)
                        
                        postBody = try JSONSerialization.data(withJSONObject: reqDict, options:JSONSerialization.WritingOptions.prettyPrinted) as NSData
                        print(postBody as Any)
                    }
                    
                } catch let error as NSError {
                    jsonError = error
                    postBody = nil
                }
            }
            if (jsonError != nil) {
                callBack(nil, jsonError)
                return
            }
    }
}
