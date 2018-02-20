//
//  WebServiceOperations.swift
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

public typealias SuccessCompletionHandler = (_ data : Data?) -> Void
public typealias ErrorCompletionHandler = (_ error: Error?) -> Void

public enum HTTPVerb: String {
    case GET
    case POST
    case PUT
    case DELETE
}

class WebServiceOperations : NSObject
{
    func createRequest(url : String, method : HTTPVerb, body: NSDictionary?, header : NSDictionary?,sucessCompletion : SuccessCompletionHandler?,errorCompletion:ErrorCompletionHandler?) {
        let requestURL = URL(string: url)
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: requestURL!)
        request.httpMethod = method.rawValue
        if method.rawValue == HTTPVerb.POST.rawValue {
            
            if body != nil {
                if let jsondata = try? JSONSerialization.data(withJSONObject:body! , options: .prettyPrinted) {
                    request.httpBody = jsondata
                }
            }
        }
        if header != nil  {
            for (key, value) in header! {
                request.addValue(value as! String, forHTTPHeaderField: key as! String)
            }
        }
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            if let error = error {
                // print(error)
                if let errorCompletion = errorCompletion {
                    errorCompletion(error)
                }
            }
            else if let data = data {
                // print(data)
                if let dataCompletion = sucessCompletion {
                    dataCompletion(data)
                }
            }
            else {
                if let errorCompletion = errorCompletion {
                    errorCompletion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : ""]))
                }
            }
        })
        task.resume()
    }
    
}


