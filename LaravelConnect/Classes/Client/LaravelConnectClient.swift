//
//  LaravelConnectClient.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 19/11/2017.
//


import Foundation

class HttpTask: LaravelTask {
    
    let task : URLSessionDataTask
    
    public init(sessionTask: URLSessionDataTask){
        self.task = sessionTask
    }
    
    func cancel() {
        self.task.cancel()
    }
    
    func start() {
        self.task.resume()
    }
  
}

class LaravelConnectClient: NSObject {
    
    let settings : LaravelSettings
    let session : URLSession
    
    public init(settings: LaravelSettings){
        self.settings = settings
        self.session = LaravelConnectClient.setupURLSession(settings: settings)
        
        super.init()
    }
    
    private class func setupURLSession(settings: LaravelSettings) -> URLSession {
        
        var sessionConfiguration : URLSessionConfiguration
        
        if(settings.cacheDisabled){
            sessionConfiguration = .ephemeral
        }else {
            sessionConfiguration = .default
        }
        
        return URLSession(configuration: sessionConfiguration)
    }
    
    public func buildLaravelTask(request: LaravelRequest) -> LaravelTask {
        
        let httpRequest = self.buildURLRequest(request: request)
        
        let dataTask = self.buildDataTask(request: httpRequest,
                                successHandler: request.successHandler!,
                                dataHandler: request.parseDataBlock!,
                                errorHandler: request.errorHandler!)
        
        return HttpTask(sessionTask: dataTask)
    }
    
    private func buildDataTask(request: URLRequest,
                                    successHandler: @escaping SuccessBlock,
                                    dataHandler: @escaping ParseDataBlock,
                                    errorHandler: @escaping ErrorBlock) -> URLSessionDataTask{
        
        let dataTask : URLSessionDataTask = self.session.dataTask(with: request, completionHandler:
        { (data: Data?, response: URLResponse?, error: Error?) in
            
            if let error = error {
                errorHandler(error)
                return
            }
            
            if let _ = response ,
                let parsedData = dataHandler(data) {//parse NSData to Json
                successHandler(parsedData)//parse the JSON
            }else { //  the data format is incorrect or there is no data
                let dataError = NSError(domain: "json.data.format", code: -100, userInfo: nil);
                errorHandler(dataError)
            }
        })
        
        return dataTask
    }
    
    
    //given a LaravelRequest builds the URLComponents for the Http DataTask
    private func buildURLRequest(request: LaravelRequest)-> URLRequest {
        
        var components: URLComponents = URLComponents()
        
        components.scheme = request.scheme
        components.host = request.host
        
        //build path
        var path: String = ""
        for segment in request.pathComponents {
            
            let safeSegment : String = segment.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            if(safeSegment.isEmpty == false){
                path.append("/")
                path.append(safeSegment)
            }
        }
        components.path = path
        
        //any query parameter?
        for (name,value) in request.queryParameters {
            let item = URLQueryItem(name: name, value: value)
            components.queryItems?.append(item)
        }
        
        var httpRequest :URLRequest = URLRequest(url: components.url!)
        
        //set the method
        httpRequest.httpMethod = request.method.rawValue
        
        //now set the headers
        for (name,value) in request.requestHeaders {
            httpRequest.addValue(value, forHTTPHeaderField: name)
        }
        
        return httpRequest
    }
    
    
}
