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
import CoreData
import Square1CoreData

public class LaravelConnect: NSObject {
    
    private static var instance: LaravelConnect = {
        let instance = LaravelConnect()
        return instance
    }()
    
    // MARK: - Properties
    private var httpClient: LaravelConnectClient!
    private var settings: LaravelSettings!
    private var coreData: CoreDataManager!
    
    // MARK: - Methods
    public static func configure(settings : LaravelSettings, onCompletion: @escaping () -> ()){
        instance.configure(settings: settings, onCompletion: onCompletion)
    }
    
    private func configure(settings : LaravelSettings, onCompletion: @escaping () -> ()){
        self.settings = settings
        self.coreData = CoreDataManager(modelName: settings.coreDataModelName)
        
        self.coreData.initCoreDataStack (completionClosure: {
            // create API client that will make all REST requests
            self.httpClient = LaravelConnectClient(settings: settings, coredata: self.coreData)
            onCompletion()
        })

    }
    
    public static func shared() -> LaravelConnect {
        return instance;
    }
    
//    public func execute(request: LaravelRequest) -> LaravelTask {
//        let task = self.httpClient.buildLaravelTask(request: request)
//        task.start()
//        return task
//    }
    
    public func list(model: NSManagedObject.Type, relation: String = "", filter: Filter = Filter()) -> ModelList{
        return ModelList(request: self.httpClient.newModelList(model: model, relation: relation), filter: filter)
    }
    
//    private func prepareConnectRequest<T: NSManagedObject>(model: T.Type) -> LaravelRequest!
//    {
//        guard let modelPath = self.pathForModel(model: model) else {
//            return nil
//        }
//
//        let request = LaravelRequest.initRequest();
//
//        request.parseDataBlock = { (data: Data?) in
//
//            do {
//                if((data) != nil){
//                    let json = try JSONSerialization.jsonObject(with: data!)
//                    return json
//                }
//            } catch {
//                print("Error deserializing JSON: \(error)")
//            }
//            return nil
//        }
//
//        request.setScheme(scheme: self.settings.httpScheme)
//        request.setHost(host: self.settings.apiHost)
//        request.addPathSegments(segments: self.settings.apiRootPathSegments)
//        request.addPathSegment(segment: modelPath)
//
//        return request;
//    }
    
    private func pathForModel<T: NSManagedObject>(model: T.Type) -> String? {
        
        let entity = self.coreData.entityDescriptionForClass(model: model, context: self.coreData.viewContext)
        return entity?.modelPath
    }
    
    
    
}
