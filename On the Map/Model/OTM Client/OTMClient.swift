//
//  OTMClient.swift
//  On the Map
//
//  Created by milind shelat on 25/07/19.
//  Copyright © 2019 milind shelat. All rights reserved.
//

import Foundation

class OTMClient {
    
    struct Auth {
        static var key = ""
        static var sessionId = ""
        static var nickname = ""
    }
    
    enum EndPoints {
        static let base = "https://onthemap-api.udacity.com/v1/"
        
        case baseUrl
        
        case createSessionId
        
        case studentLocation
        
        case singleStudentLocation
        
        case updateStudentLocation
        
        case getUserData
        
        case logout
        
        var stringValue: String {
            switch self {
            case .baseUrl: return EndPoints.base
            case .studentLocation: return EndPoints.base + "StudentLocation?limit=100&order=-updatedAt"
            case .createSessionId: return EndPoints.base + "session"
            case .logout: return EndPoints.base + "session"
            case .updateStudentLocation: return EndPoints.base + "StudentLocation?limit=100&order=-updatedAt"
            case .singleStudentLocation: return EndPoints.base + "StudentLocation"
            case .getUserData : return EndPoints.base + "users/" + Auth.key
            }
        }
        
        var url: URL {
            
            return URL(string: stringValue)!
        }
    }
    
    
    class func taskForGetRequest<ResponseType : Decodable >(url: String,response : ResponseType.Type, completion:@escaping(ResponseType?,Error?) -> Void){
        
        let request = URLRequest(url: URL(string: url)!)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("no data")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            //            let range = (5..<data.count)
            //            let newData = data.subdata(in: range) /* subset response data! */
            //            print(String(data: newData, encoding: .utf8)!)
            
            do {
                let decoder = JSONDecoder()
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
                
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    
    
    
    class func taskForPOSTRequest<ResponseType: Decodable>(url: String, responseType: ResponseType.Type, body: Data, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = body
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if error != nil {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode else {
                
                return
            }
            if httpStatusCode >= 200 && httpStatusCode < 300 {
                // Since Status Code is valid. Process Data here only.
                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                    return
                }
                // This is syntax to create Range in Swift 5
                var newData = data
                let range = 5..<data.count
                newData = data.subdata(in: range) /* subset response data! */
                // Continue processing the data and deserialize it
                let decoder = JSONDecoder()
                do {
                    let responseObject = try decoder.decode(ResponseType.self, from: newData)
                    DispatchQueue.main.async {
                        completion(responseObject, nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        //print(error.localizedDescription)
                        completion(nil, error)
                    }
                }
            }
            switch(httpStatusCode){
            case 200..<299: print("Success")
            completion(nil,error)
                break
            case 400: print("BadRequest")
            completion(nil,error)
                break
            case 401: print("Invalid Credentials!")
            completion(nil,error)
                break
            case 403: print("Unauthorized!")
            completion(nil,error)
                break
            case 405: print("HttpMethod Not Allowed!")
            completion(nil,error)
                break
            case 410: print("URL Changed")
            completion(nil,error)
                break
            case 500: print("Server Error")
            completion(nil,error)
                break
            default:
                print("Your request returned a status code other than 2xx!")
            }
        }
        task.resume()
    }
    
    
    
    
    //            func sendError(_ error: String) {
    //                print(error)
    //                let userInfo = [NSLocalizedDescriptionKey : error]
    //                completion(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
    //            }
    //
    //            guard (error == nil) else {
    //                sendError("There was an error with your request: \(error!.localizedDescription)")
    //                return
    //            }
    //
    //            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
    //                sendError("Request did not return a valid response.")
    //                return
    //            }
    //
    //            switch (statusCode) {
    //            case 403:
    //                sendError("Please check your credentials and try again.")
    //            case 200 ..< 299:
    //                break
    //            default:
    //                sendError("Your request returned a status code other than 2xx!")
    //            }
    
    //            guard let data = data else {
    //                sendError("No data was returned by the request!")
    //                return
    //            }
    
    
    
    //let range = (5..<data.count)
    //newData = data.subdata(in: range)
    
    //            let decoder = JSONDecoder()
    //            do {
    //                let responseObject = try decoder.decode(ResponseType.self, from: newData)
    //                DispatchQueue.main.async {
    //                    completion(responseObject, nil)
    //                }
    //            } catch {
    //                DispatchQueue.main.async {
    //                    completion(nil, error)
    //                }
    //            }
    //        }
    //        task.resume()
    
    
    class func login(username: String, password: String, completion: @escaping (Int?,String?, Bool, Error?) -> Void){
        
        let body = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        
        taskForPOSTRequest(url: EndPoints.createSessionId.stringValue, responseType: NewSession.self, body: body!) { (response, error) in
            if let response = response {
                //print(response.account.key)
                //print(response.session.id)
                OTMClient.Auth.sessionId = response.session.id
                OTMClient.Auth.key = response.account.key
                completion(Int(OTMClient.Auth.key),OTMClient.Auth.sessionId,true, nil)
            } else {
                //print(error!)
                completion(nil,nil,false,error)
            }
        }
    }
    
    class func getUserData(completion: @escaping (UserDataResponse?, Error?) -> Void){
        
        let url = EndPoints.getUserData.url
        let request = URLRequest(url: url)
        let downloadTask = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            // Guard to make sure there is no error. If error, it will exit into Guard and return
            // Just an error. Error carried to calling function for use.
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            // First 5 chars returned from API must be stripped away before using the returned
            // JSON data for decoding into StudentInfo
            let range = (5..<data.count)
            let newData = data.subdata(in: range)
            let jsonDecoder = JSONDecoder()
            do {
                //Decode data into StudentInfo
                let result = try jsonDecoder.decode(UserDataResponse.self, from: newData)
                
                DispatchQueue.main.async {
                    //data was able to decode into StudentInfo
                    completion(result, nil)
                }
            } catch {
                //Failed to Decode StudentInfo
                DispatchQueue.main.async {
                    print(error.localizedDescription)
                    completion(nil,error)
                }
            }
        }
        downloadTask.resume()
        
    }
    
    class func getStudentLocation(completion:@escaping([StudentInformation],Error?) -> Void){
        
        taskForGetRequest(url: EndPoints.studentLocation.stringValue, response: StudentResult.self) { (response, error) in
            guard let response = response else {
                print(error!)
                completion([],error)
                return
            }
            completion(response.results,nil)
        }
    }
    
    class func updateStudentLocation(completion:@escaping([StudentInformation],Error?) -> Void){
        taskForGetRequest(url: EndPoints.updateStudentLocation.stringValue, response: StudentResult.self) { (response, error) in
            guard let response = response else {
                print(error!)
                completion([],error)
                return
            }
            completion(response.results,nil)
        }
    }
    
    class func requestPostStudentInfo(postData:NewLocation, completionHandler: @escaping (PostLocationResponse?,Error?)->Void) {
        let jsonEncoder = JSONEncoder()
        let encodedPostData = try! jsonEncoder.encode(postData)
        let body = encodedPostData
        print(encodedPostData)
        
        taskForPOSTRequest(url: EndPoints.singleStudentLocation.stringValue, responseType: NewLocation.self, body: body) { (response, error) in
            if let response = response {
                //completionHandler(response,nil)
            } else {
                //print(error!)
                completionHandler(nil,error)
            }
        }
    }
    
    class func logout(completion:@escaping() -> Void){
        var request = URLRequest(url: URL(string: EndPoints.logout.stringValue)!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                
                return
            }
            let range = (5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            print(String(data: newData!, encoding: .utf8)!)
            completion()
        }
        task.resume()
    }
    
}















