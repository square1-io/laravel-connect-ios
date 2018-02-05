// Copyright © 2017 Square1.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//  Created by Roberto Prato on 19/11/2017.
//

import Foundation
import Square1Network

//Transform the binary data received during an http request to
// a manageable format such as JSON or an Image
public typealias ParseDataBlock = (_ : Data?) -> Any?

//called if request was successfull with the data from ParseDataBlock
public typealias SuccessBlock = (_ : Any?) -> Void

//Handle request Errors
public typealias ErrorBlock = (_ : Error?) -> Void



public protocol LaravelServiceResponse: WebServiceResponse {
   init(with dictionary: [String: Any])
}

public protocol LaravelServiceRequest: WebServiceRequest where Task: URLSessionDataTask, Response: LaravelServiceResponse {
    func handleResponse(_ data: Data?, response: URLResponse?, error: NSError?) -> WebServiceResult<Response>
}

public extension LaravelServiceRequest {
    var accept: MIMEType? { return .json }
    
    @discardableResult
    func executeInSession(_ session: URLSession? = URLSession.shared,
                          completion: @escaping (WebServiceResult<Response>) -> ()) -> URLSessionDataTask? {
        let request = createRequest() as URLRequest
        
        let task = session!.dataTask(with: request) { data, response, error in
            let result = self.handleResponse(data, response: response, error: error as NSError?)
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        task.resume()
        return task
    }
}


public class LaravelResponse: LaravelServiceResponse {

    let data: [String : Any]
    
    public required init(with dictionary: [String: Any]) {
        self.data = dictionary["data"] as! [String : Any]
    }
}

public class LaravelPaginatedResponse: LaravelResponse {
    
    var pagination: Pagination?
    
    public required init(with dictionary: [String : Any]) {
       super.init(with: dictionary)
       self.pagination = Pagination(with: self.data["pagination"] as! [String : Any])
    }

    public func page() -> Pagination? {
        return pagination
    }
}

public class LaravelRequest: LaravelServiceRequest, LaravelTask   {
    
    public enum State {
        case Idle
        case Running
        case Finished
        case Failed
    }
    
    public typealias Response = LaravelResponse
    
    public var accept: MIMEType? { return .json }

    public private(set) var state:State
    
    public func cancel() {
        self.task?.cancel()
    }
    
    public func start(success:@escaping(LaravelResponse) -> (), failure:@escaping(Error) -> () ) {
        self.state = .Running
        self.task = executeInSession(self.session, completion: { (result) in
            
            switch (result) {
            case .success(let response):
                success(response)
                break
            case .failure(let error):
                failure(error)
            default:
                break
            }
            
        } )
    }

    public private(set) var baseUrl: URL
    public private(set) var method: HTTPMethod
    public private(set) var path: Array<String>
    
    public var headerParams: [HeaderItem]  {
            get { return Array(self.headersDictionary.values) }
    }

    public var queryParams: [URLQueryItem]  {
        get { return Array(self.queryParamsDictionary.values) }
    }
    
    private var headersDictionary: Dictionary<String,HeaderItem>
    private var queryParamsDictionary: Dictionary<String,URLQueryItem>
    
    private let session: URLSession
    private var task: Task?
    private var responseType : Response.Type
    private var responseFactory : LaravelResponseFactory
    
    init(method: HTTPMethod = HTTPMethod.GET,
          scheme: String = "http",
          host: String,
          session: URLSession,
          responseType: Response.Type = LaravelPaginatedResponse.self)   {
        self.state = .Idle
        self.method = method
        self.session = session
        self.responseType = responseType
        self.responseFactory = LaravelDefaultResponseFactory()
        self.baseUrl = URL(string: "\(scheme)://\(host)")!
        self.path = Array()
        self.headersDictionary = Dictionary()
        self.queryParamsDictionary = Dictionary()
        self.addRequestHeader(name:"Content-Type", value:"application/json")
        
    }

    public func setResponseFactory(responseFactory: LaravelResponseFactory){
        self.responseFactory = responseFactory
    }
    public func addPathSegment(segment: String){
        self.path.append(segment)
    }
    
    public func addPathSegments(segments: [String]){
        for segment in segments {
            self.path.append(segment)
        }
    }
    
    public func addQueryParameter(name:String, value:String){
        self.queryParamsDictionary[name] = URLQueryItem(name:name, value:value)
    }
    
    public func addRequestHeader(name:String, value:String){
        self.headersDictionary[name] = HeaderItem(name:name, value:value)
    }
    
    public func handleResponse(_ data: Data?, response: URLResponse?, error: NSError?) -> WebServiceResult<Response> {
        
        if let error = error {
            self.state = .Failed
            return .failure(error)
        }
        
        guard let data = data else {
            self.state = .Finished
            return .successNoData
        }
        
        do{
            
#if DEBUG
     let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
    print(json)
#endif
            let laravelResponse = try self.responseFactory.responseForData(data)
            self.state = .Finished
            return .success(laravelResponse)
            
        } catch let error as NSError {
#if DEBUG
    print(error)
#endif
            self.state = .Failed
            return .failure(error)
        }

    }
    
    @discardableResult
    public func executeInSession(_ session: URLSession? = URLSession.shared,
                          completion: @escaping (WebServiceResult<Response>) -> ()) -> URLSessionDataTask? {
        let request = createRequest() as URLRequest
        
        let task = session!.dataTask(with: request) { data, response, error in
            let result = self.handleResponse(data, response: response, error: error as NSError?)
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        task.resume()
        return task
    }
}



extension LaravelRequest {
    
    public func setPage(page: Int) {
        self.addQueryParameter(name: "page", value: String(page))
    }

}




