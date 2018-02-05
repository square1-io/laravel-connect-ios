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
import Square1CoreData
import Square1Network
import CoreData


class LaravelConnectClient {
    
    private let coredata: CoreDataManager
    let settings: LaravelSettings
    let session: URLSession
    
    public init(settings: LaravelSettings, coredata: CoreDataManager){
        self.settings = settings
        self.coredata = coredata
        
        //setup default session
        var sessionConfiguration : URLSessionConfiguration
        
        if(settings.cacheDisabled){
            sessionConfiguration = .ephemeral
        }else {
            sessionConfiguration = .default
        }
        
        
        self.session = URLSession(configuration: sessionConfiguration)
    }
    
    /**
     Creates new instance of a LaravelRequest.
     
     @param method, HTTPMethod
     
     @return LaravelRequest.
     */
    private func newRequest(method: HTTPMethod = HTTPMethod.GET) -> LaravelRequest? {
        
        let request =  LaravelRequest(method: method,
                              scheme: settings.httpScheme,
                              host: settings.apiHost,
                              session: self.session)
        
        self.addCommonHeadersToRequest(request: request)
        
        return request;
        
    }
    
    /**
     Creates new instance of a LaravelRequest pointing to the root of the connect endpoints
     as specified in the settings.
     
     @param method, HTTPMethod
     
     @return LaravelRequest.
     */
    private func newConnectRequest(method: HTTPMethod = HTTPMethod.GET) -> LaravelRequest? {
        
        let request = self.newRequest(method: method)
        
        request?.addPathSegments(segments: self.settings.apiRootPathSegments)
        
        return request
        
    }
    
    private func addCommonHeadersToRequest(request: LaravelRequest) {
        
        let authToken = Auth.shared.token()

        if(authToken != nil) {// add Authorization Bearer
            request.addRequestHeader(name: "Authorization", value: "Bearer " + authToken!)
        }
        
        // is there an API Key we need to add ?
        if(!self.settings.apiKeyValue.isEmpty) {
            request.addRequestHeader(name: self.settings.apiKeyHeaderName, value: self.settings.apiKeyValue)
        }
        
    }

    public func newModelList(model: ConnectModel.Type, relation: String = "", include:[String] = []) -> LaravelRequest {
        
        let request = self.newConnectRequest()
        request?.setResponseFactory(responseFactory: LaravelCoreDataMoldelListResponseFactory(coreData:self.coredata, model:model))

        if let modelPah:String = self.coredata.pathForModel(model: model) {
            request?.addPathSegment(segment: modelPah)
        }
        
        if  include.count > 0 {
            let value = include.joined(separator: ",")
            request?.addQueryParameter(name: "include", value: value)
        }
        
        if !relation.isEmpty {
            request?.addPathSegment(segment: relation)
        }
        
        return request!
    }
    
}
