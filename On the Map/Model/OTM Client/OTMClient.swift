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
    }
    
    enum EndPoints {
        static let base = "https://onthemap-api.udacity.com/v1/"
        
        case baseUrl
        
        case createSessionId
        
        case studentLocation
        
        case singleStudentLocation
        
        case updateStudentLocation
        
        case logout
        
        var stringValue: String {
            switch self {
                //"https://onthemap-api.udacity.com/v1/StudentLocation?order=-updatedAt"
            //https://onthemap-api.udacity.com/v1/StudentLocation?limit=100  ?limit=100&order=-updatedAt
            case .baseUrl: return EndPoints.base
            case .studentLocation: return EndPoints.base + "StudentLocation?limit=100&order=-updatedAt"
            case .createSessionId: return EndPoints.base + "session"
            case .logout: return EndPoints.base + "session"
            case .updateStudentLocation: return EndPoints.base + "StudentLocation?limit=100&order=-updatedAt"
            case .singleStudentLocation: return EndPoints.base + "StudentLocation"
            }
        }
        
        var url: URL {
            
            return URL(string: stringValue)!
        }
    }

    
    class func taskForGetRequest<ResponseType : Decodable >(url: String,response : ResponseType.Type, completion:@escaping(ResponseType?,Error?) -> Void){
        
        let request = URLRequest(url: URL(string: url)!)
        //print(request)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("no data")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
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
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
                
            }
            
            let range = (5..<data.count)
            let newData = data.subdata(in: range)
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: newData)
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
    
    class func login(username: String, password: String, completion: @escaping (Int?,String?, Bool, Error?) -> Void){
        
        let body = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        
        taskForPOSTRequest(url: EndPoints.createSessionId.stringValue, responseType: NewSession.self, body: body!) { (response, error) in
            if let response = response {
                print(response.account.key)
                print(response.session.id)
                OTMClient.Auth.sessionId = response.session.id
                OTMClient.Auth.key = response.account.key
                completion(Int(OTMClient.Auth.key),OTMClient.Auth.sessionId,true, nil)
            } else {
                //print(error)
                completion(nil,nil,false,error)
            }
        }
    }
    
    class func getStudentLocation(completion:@escaping([StudentInformation],Error?) -> Void){
        
        taskForGetRequest(url: EndPoints.studentLocation.stringValue, response: StudentResult.self) { (response, error) in
            if let response = response {
                completion(response.results,nil)
            } else {
                completion([],error)
            }
        }
    }
    
    class func updateStudentLocation(completion:@escaping([StudentInformation],Error?) -> Void){
        taskForGetRequest(url: EndPoints.updateStudentLocation.stringValue, response: StudentResult.self) { (response, error) in
            if let response = response{
                completion(response.results,nil)
            } else {
                completion([],error)
            }
        }
    }
    
    class func requestPostStudentInfo(postData:NewLocation, completionHandler: @escaping (PostLocationResponse?,Error?)->Void) {
        let jsonEncoder = JSONEncoder()
        let encodedPostData = try! jsonEncoder.encode(postData)
        let body = encodedPostData
        print(encodedPostData)
        
        taskForPOSTRequest(url: EndPoints.singleStudentLocation.stringValue, responseType: NewLocation.self, body: body) { (response, error) in
            if let response = response {
                print(response.firstName)
                print(response.lastName)
                //completionHandler(response,nil)
            } else {
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















