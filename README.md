iOS Basic Template
========================
This is a basic [Xcode] project template created as reusable component which serve as a starting point for anyone who wants to build a native iOS app.

## Getting Started

- Rename the template project
- Install cocoapods, Update POD file, Run pod update command
- Rename Targets
- Manage Schemes -> Autocreate schemes
- Rename iOSTemplate project folder
- Rename iOSTemplateTest folder
- Rename iOSTemplateUITest folder
- Verify  and update the info.plist path in Build settings
- Update bundle identifier

## How to Integrate

-API Communication

1. Using basic communication handler

let webServiceOperation = WebServiceOperations()
let urlString = BASE_URL + "requesturl"

webServiceOperation.createRequest(url: urlString, method: .POST, body: requestDictionary, header: nil, sucessCompletion: { (data) in
if let data = data {
do {
let jsonData = try JSONSerialization.jsonObject(with: data, options:[.allowFragments,.mutableLeaves,.mutableContainers])

if let jsonDict = jsonData as? NSDictionary {
print(jsonDict)
}
}
catch {

}
}

}) { (error) in

}

2. Using Alamofire


// Make the API Call using the Alamofire
//Create URL request

Alamofire.request(request).responseJSON { response in

// Safely unwarp and validate the response status
guard response.result.isSuccess else {
return completionHandler(nil, response.error)
}

// Safely unwarp and validate the response value
guard let responseJSON = response.result.value as? [String : Any] else {
return completionHandler(nil, response.error)
}

// Return the success reponse dictionary
completionHandler(responseJSON, nil)
}

## License

This project is licensed under the MIT License.

