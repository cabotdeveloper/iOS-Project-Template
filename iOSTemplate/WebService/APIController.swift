//
//  APIController.swift
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
import Alamofire

class APIController: NSObject {

    // This class will list all the API functions need to be implemented in the application.
    // All API calls should go through this class
    // Common features like parsing the response will be implemented here.
    var sessionAvailable : URLSession!
    
    override init() {
        if sessionAvailable == nil {
            sessionAvailable = URLSession.shared
        }
    }
    
    func createAndStoreAesKey() {
        
    }
    
    func initializeApp(dict: NSDictionary, withApi api: String, callBack:(_ responseDict: NSDictionary?, _ error: NSError?) -> ()) {
        
            var jsonError : NSError?
            var requestBody: NSData?
            var requestDictionary: NSDictionary  = [:]

            if dict.allKeys.count > 0 {
                do {
                    requestBody = try JSONSerialization.data(withJSONObject: dict, options:JSONSerialization.WritingOptions.prettyPrinted) as NSData
                    let jsonString = String.init(data: requestBody! as Data, encoding: String.Encoding.utf8)
                    
                    if jsonString != nil {
//                        print(jsonString as Any)
                        let encryptedJson = Utilities.encrypt(jsonString!)
                        requestDictionary = NSDictionary.init(object: encryptedJson, forKey: ENCRYPTED_DATA as NSCopying)
                        requestBody = try JSONSerialization.data(withJSONObject: requestDictionary, options:JSONSerialization.WritingOptions.prettyPrinted) as NSData
                    }
                    
                } catch let error as NSError {
                    jsonError = error
                    requestBody = nil
                }
                
                /** Use Basic communication -> WebServiceOperations
                 OR
                 Alamofire
                 for API Communication **/
                                
            }
            if (jsonError != nil) {
                callBack(nil, jsonError)
                return
            }
    }
}
