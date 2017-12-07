//
//  LaravelConnect.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 19/11/2017.
//

import Foundation
import CoreData

public class LaravelConnect: NSObject {
    
    private static var sInstance: LaravelConnect?
    
    private let httpClient : LaravelConnectClient
    private let settings: LaravelSettings
    private let coreData: CoreDataManager
    
    private init(settings : LaravelSettings) {
        self.settings = settings
        
        self.coreData = CoreDataManager(modelName: settings.coreDataModelName)
        self.coreData.initCoreDataStack(completionClosure: {})
        // create API client that will make all REST requests
        self.httpClient = LaravelConnectClient(settings: settings)
        
        super.init()
    }
    
    public class func setup(settings : LaravelSettings){
        
        let laravelConnect = LaravelConnect(settings: settings)
        sInstance = laravelConnect
        
        // init Auth 
        Auth.setup(laravelConnect:laravelConnect)
    }
    
    
    public static func list<T: NSManagedObject>(model: T.Type) -> ModelList{
        return (sInstance?._list(model: model))!
    }
    
    static func execute(request: LaravelRequest) -> LaravelTask{
        return (sInstance?._execute(request:request))!
    }
    
    private func _execute(request: LaravelRequest) -> LaravelTask{
        let task = self.httpClient.buildLaravelTask(request: request)
        task.start()
        return task
    }
    
    private func _list<T: NSManagedObject>(model: T.Type) -> ModelList{
        return ModelList(request: self._prepareConnectRequest(model: model))
    }
    
    private func _prepareConnectRequest<T: NSManagedObject>(model: T.Type) -> LaravelRequest!
    {
        guard let modelPath = self._pathForModelClass(model: model) else {
            return nil
        }
        
        let request = LaravelRequest.initRequest();
        
        request.parseDataBlock = { (data: Data?) in
            
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
        
        request.setScheme(scheme: self.settings.httpScheme)
        request.setHost(host: self.settings.apiHost)
        request.addPathSegments(segments: self.settings.apiRootPathSegments)
        request.addPathSegment(segment: modelPath)
        
        return request;
    }
    
    private func _pathForModelClass<T: NSManagedObject>(model: T.Type) -> String? {
        
        let entity = self.coreData.entityDescriptionForClass(model: model, context: self.coreData.mainContext)
        return entity?.modelPath
    }
    
    
    
}
