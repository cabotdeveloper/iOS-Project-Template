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
    
    func initializeApp(dict: NSDictionary, withApi api: String, callBack:(_ responseDict: NSDictionary?, _ error: NSError?) -> ()) {
    }
}
