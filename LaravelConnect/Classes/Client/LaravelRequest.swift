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


public struct LaravelResponse: JSONServiceResponse {
    
    public init(jsonObject: Decodable) {
        
    }
}

public class LaravelRequest: JSONServiceRequest, LaravelTask {
    
    
    public func cancel() {
        
    }
    
    public func start() {
        
    }
    
    
    
    public func execute(){
        
    }
    
    public typealias Response = LaravelResponse
    
    public private(set) var baseUrl: URL
    public private(set) var method: HTTPMethod
    public private(set) var path: Array<String>
    public private(set) var headerParams: [HeaderItem]
    public private(set) var queryParams: [URLQueryItem]
    
    
    private let session: URLSession
    
    init(method: HTTPMethod = HTTPMethod.GET,
          scheme: String = "http",
          host: String,
          session: URLSession)  {
        
        self.method = method
        self.session = session
        self.baseUrl = URL(string: "\(scheme)://\(host)")!
        self.path = Array()
        self.queryParams = Array()
        self.headerParams = Array()
        self.addRequestHeader(name:"Content-Type", value:"application/json")
        
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
        self.queryParams.append(URLQueryItem(name:name, value:value))
    }
    
    public func addRequestHeader(name:String, value:String){
        self.headerParams.append(HeaderItem(name:name, value:value))
    }
    
    
    public func handleResponse(_ data: Data?, response: URLResponse?, error: NSError?) -> WebServiceResult<LaravelResponse> {
        if let error = error {
            return .failure(error)
        }
        
        return .successNoData
        
        //        guard let data = data else {
        //            return .successNoData
        //        }
        //
        //        do {
        //            let j = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        //            print(j)
        //
        //            let decoder = JSONDecoder()
        //            let json = try decoder.decode([Post].self, from: data)
        //            let response = LaravelResponse(jsonObject: json)
        //            return .success(response)
        //        } catch let error as NSError {
        //            return .failure(error)
        //        }
        
    }
    
}

extension LaravelRequest {
    
    public func setPage(page: Int) {
        self.addQueryParameter(name: "page", value: String(page))
    }
    
}
