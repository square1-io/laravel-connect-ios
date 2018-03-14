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


//Transform the binary data received during an http request to
// a manageable format such as JSON or an Image
public typealias ParseDataBlock = (_ : Data?) -> Any?

//called if request was successfull with the data from ParseDataBlock
public typealias SuccessBlock = (_ : Any?) -> Void

//Handle request Errors
public typealias ErrorBlock = (_ : Error?) -> Void



public protocol LaravelServiceResponse: WebServiceResponse {
   init(data:Data) throws
}

public protocol LaravelServiceRequest: WebServiceRequest where Task: URLSessionDataTask, Response: LaravelServiceResponse {
    func handleResponse(_ data: Data?, response: URLResponse?, error: NSError?) -> WebServiceResult<Response>
}

public extension LaravelServiceRequest {
    var accept: String? { return "application/json" }
    
}

public enum LaravelRequestError : Error {
    case InvalidData
}

public class LaravelResponse: LaravelServiceResponse {
   
    let json:[String:AnyObject]
   // let error:[String:AnyObject]
    
    public required init(data: Data) throws {
        
        self.json = try LaravelResponse.parseData(data: data.toJson())
        try LaravelResponse.parseError(json: self.json)

    }

    private static func parseData(data:[String:AnyObject]?) throws -> [String:AnyObject] {
        
        if let j:[String:AnyObject] = data, let d:[String:AnyObject] = j.dictionaryValueForKey(key: "data")  {
            return d
        }
        
         throw LaravelRequestError.InvalidData
    }
    
    private static func parseError(json:[String:AnyObject]) throws {
        if let e:[String:AnyObject] = json.dictionaryValueForKey(key: "error"){
            //self.error = e
            throw LaravelRequestError.InvalidData
        }
    }

    open func storeModelObjects(coreData: CoreDataManager, model: ConnectModel.Type) throws {
        
    }
}

public class LaravelPaginatedResponse: LaravelResponse {
    
    var pagination: Pagination?
    
      public required init(data: Data) throws {
       try super.init(data: data)

        if let pagData:[String: Any] = self.json.dictionaryValueForKey(key: "pagination") {
            self.pagination = Pagination(with: pagData)
        }else {
            self.pagination = Pagination()
        }
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
    
    public var contentType: String? {
        return "application/json"
    }
    
    public var accept: String? { return  "application/json" }
    public var requestBody: Data? { return nil }
    
    public private(set) var state:State
    
    public func cancel() {
        self.state = .Failed
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
                failure(error!)
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
       
        
    }
    
    init(request:LaravelRequest){
        self.state = .Idle
        self.method = request.method
        self.session = request.session
        self.responseType = request.responseType
        self.responseFactory = request.responseFactory
        self.baseUrl = request.baseUrl
        self.path = request.path
        self.headersDictionary = request.headersDictionary
        self.queryParamsDictionary = request.queryParamsDictionary
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
    
    public func sort(sort:Sort) -> LaravelRequest{
        
        clearQueryParametesMatchingName(paramName:sort.paramName)
        
        let sortingOptions = sort.serialize()
        for(name,value) in sortingOptions {
            self.addQueryParameter(name: name, value: value)
        }
        return self
    }
    
    public func filter(filter:Filter) -> LaravelRequest{
        
        clearQueryParametesMatchingName(paramName:filter.paramName)
        
        let filterOptions = filter.serialize()
        for(name,value) in filterOptions {
            self.addQueryParameter(name: name, value: value)
        }
        return self
    }
    
    public func addQueryParameter(name:String, value:String){
        self.queryParamsDictionary[name] = URLQueryItem(name:name, value:value)
    }
    
    public func addRequestHeader(name:String, value:String){
        self.headersDictionary[name] = HeaderItem(name:name, value:value)
    }
    
    private func clearQueryParametesMatchingName(paramName:String){
        
        let queryParamsCopy = self.queryParamsDictionary
        for (name,_) in queryParamsCopy {
            if  name.hasPrefix(paramName){
                self.queryParamsDictionary.removeValue(forKey: name)
            }
        }
    }
    
    public func serializeArray(output:inout [String:String], name:String, values:Array<Any>){

        for (key, value) in values.enumerated(){
            let currentName = "\(name)[\(key)]"
            switch value {
                case _  as Array<Any>:
                    self.serializeArray(output: &output, name: currentName, values: value as! Array<Any>)
                break
            case  _ as Dictionary<String,Any>:
                self.serializeDictionary(output: &output, name: currentName, values: value as! Dictionary<String,Any>)
                break
                 default:
                    output[currentName] = String(describing:value)
                break
            }
        }
    }
    
    public func serializeDictionary(output:inout [String:String], name:String, values:Dictionary<String,Any>){
        
        for (key, value) in values{
            let currentName = "\(name)[\(key)]"
            switch value {
            case _  as Array<Any>:
                self.serializeArray(output: &output, name: currentName, values: value as! Array<Any>)
                break
            case  _ as Dictionary<String,Any>:
                self.serializeDictionary(output: &output, name: currentName, values: value as! Dictionary<String,Any>)
                break
            default:
                output[currentName] = String(describing:value)
                break
            }
        }
    }
    
    
    public func handleResponse(_ data: Data?, response: URLResponse?, error: NSError?) -> WebServiceResult<Response> {
        
        if let error = error {
            self.logError(error: error)
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
            
        } catch let error as Error {
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
        let request = self.request as URLRequest
#if DEBUG
    print(String(describing:request.url))
#endif

        let task = session!.dataTask(with: request) { data, response, error in
            let result = self.handleResponse(data, response: response, error: error as NSError?)
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        task.resume()
        return task
    }

    private func logError(error:Error){
#if DEBUG
        print("ERROR = \(error.localizedDescription)")
#endif
    }
   
}



extension LaravelRequest {
    
    public func setPage(page: Int) {
        self.addQueryParameter(name: "page", value: String(page))
    }

}

class LaravelPostRequest: LaravelRequest {
    
    var files: [FileUpload]!
    var bodyParams: [String: String]!
    
    override var method: HTTPMethod { return .POST }
    
    var boundary: String  {
        return "boundary-d481cbe95f0e7a59ec7f93e6ede5dd05e3291a3c"
    }
    

    override public var contentType: String? {
        return "multipart/form-data; boundary=\(boundary)"
    }
    
    init(scheme: String = "http",
         host: String,
         session: URLSession,
         responseType: Response.Type = LaravelPaginatedResponse.self)   {
        super.init(method: .POST, scheme: scheme, host: host, session: session, responseType: responseType)
        self.files = []
        self.bodyParams = [:]
    }
    
    init(request:LaravelPostRequest){
        super.init(request: request)
        self.files = request.files
        self.bodyParams = request.bodyParams
    }
    
   override public var requestBody: Data?   {
        
        let body = NSMutableData()
        
        // Request Body
        for file in files {
            body.append(data(for: file))
        }
        
        for (key, value) in bodyParams {
            body.append(data(for: key, and: value))
        }
        
        if body.length > 0 {
            body.append("--\(boundary)--")
            
        }
#if DEBUG
    print(String(data: body as Data, encoding: String.Encoding.utf8) as String!)
#endif
        return body as Data
        
    }

    public func addPostParam(name:String, file value:UploadedImage) {
        if let image:UIImage = value.image, let imageData:Data = UIImagePNGRepresentation(image) {
            var fileUpload = FileUpload(data: imageData, name: name, fileName: name, mimeType: "image/png")
            self.files.append(fileUpload)
        }
    }
    
    public func addPostParam(name:String, value:Any) {
        self.bodyParams[name] = String(describing: value)
    }

    public func addPostParamArray(name:String, values:Array<Any>) {
        
        var out = Dictionary<String,String>();
        self.serializeArray(output: &out, name: name, values: values)
        
        for(name,value) in out {
           self.addPostParam(name: name, value: value)
        }
    }
    
    public func addPostParamDictionary(name:String, values:Dictionary<String,Any>) {
        
        var out = Dictionary<String,String>();
        self.serializeDictionary(output: &out, name: name, values: values)
        
        for(name,value) in out {
            self.addPostParam(name: name, value: value)
        }
    }
    
 
    
    // MARK: - Private
    fileprivate func data(for file: FileUpload) -> Data {
        let data = NSMutableData()
        
        data.append("--\(boundary)\r\n")
        data.append("Content-Disposition: attachment; name=\"\(file.name)\"; filename=\"\(file.fileName)\"\r\n")
        
        if let mimeType = file.mimeType {
            data.append("Content-Type: \(mimeType)\r\n\r\n")
        } else {
            data.append("Content-Type: application/octet-stream\r\n\r\n")
        }
        
        data.append(file.data)
        data.append("\r\n")
        
        return data as Data
    }
    
    fileprivate func data(for key: String, and value: String ) -> Data {
        let data = NSMutableData()
        
        data.append("--\(boundary)\r\n")
        data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
        data.append("\(value)\r\n")
        
        return data as Data
    }
    
}

public class LaravelRequestFactory {
    
   public static func initRequest(method: HTTPMethod = HTTPMethod.GET,
                               scheme: String = "http",
                               host: String,
                               session: URLSession,
                               responseType: LaravelResponse.Type = LaravelPaginatedResponse.self) -> LaravelRequest{
        
        switch method {
        case .POST:
            return LaravelPostRequest(scheme: scheme, host: host, session: session, responseType: responseType)
        default:
            return LaravelRequest(method: method, scheme: scheme, host: host, session: session, responseType: responseType)
        }
        
    }
    
}



