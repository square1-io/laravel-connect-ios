//
//  LaravelRequest.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 19/11/2017.
//

import Foundation

//Transform the binary data received during an http request to
// a manageable format such as JSON or an Image
typealias ParseDataBlock = (_ : Data?) -> Any?

//called if request was successfull with the data from ParseDataBlock
typealias SuccessBlock = (_ : Any?) -> Void

//Handle request Errors
typealias ErrorBlock = (_ : Error?) -> Void


class LaravelRequest: NSObject {
    
    enum Method: String {
       case GET = "GET", POST = "POST" , DELETE = "DELETE"
    }

    public private(set) var scheme : String
    public private(set) var host : String
    public private(set) var method : Method
    public private(set) var pathComponents: Array<String>
    public private(set) var queryParameters: Dictionary<String, String>
    public private(set) var requestHeaders: Dictionary<String, String>
    public private(set) var bodyParameters: Dictionary<String, Any>
    
    public var successHandler: SuccessBlock?
    public var errorHandler: ErrorBlock?
    public var parseDataBlock: ParseDataBlock?
    
    private override init()  {
        self.method = Method.GET
        self.scheme = "http"
        self.host = ""
        self.pathComponents = Array()
        self.queryParameters = Dictionary()
        self.bodyParameters = Dictionary()
        self.requestHeaders = Dictionary()
        
        //by default we parse Json
        self.parseDataBlock = {(data: Data?) in
            
            do {
                if((data) != nil){
                    let json = try JSONSerialization.jsonObject(with: data!)
                    return json
                }
            } catch {
                print("Error deserializing JSON: \(error)")
            }
            return nil
        }
             
        super.init()
    }

    public func setHost(host: String){
        self.host = host
    }
    
    public func setScheme(scheme: String){
        self.scheme = scheme
    }
    
    public func setMethod(method: Method){
        self.method = method
    }
    
    public func addPathSegment(segment: String){
        self.pathComponents.append(segment)
    }
    
    public func addPathSegments(segments: [String]){
        for segment in segments {
            self.pathComponents.append(segment)
        }
    }
    
    public func addQueryParameter(name:String, value:String){
        self.queryParameters[name] = value
    }
    
    public func addRequestHeader(name:String, value:String){
        self.requestHeaders[name] = value
    }
    
    public class func initRequest() -> LaravelRequest {
        return LaravelRequest()
    }
    
    public func execute() -> LaravelTask{
        return LaravelConnect.execute(request: self)
    }
}

extension LaravelRequest {
    
    public func setPage(page: Int) {
        self.addQueryParameter(name: "page", value: String(page))
    }

}
