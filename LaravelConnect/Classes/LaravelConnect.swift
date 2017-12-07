//
//  LaravelConnect.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 19/11/2017.
//

import Foundation
import CoreData

public class LaravelConnect: NSObject {
    
    static let sharedInstance = LaravelConnect()
    
    private var httpClient : LaravelConnectClient!
    private var settings: LaravelSettings!
    private var coreData: CoreDataManager!
    

    public func setup(settings : LaravelSettings){
      
      guard self.settings == nil else {
        return
      }
      
      self.settings = settings
      self.coreData = CoreDataManager(modelName: settings.coreDataModelName)
      self.coreData.initCoreDataStack(completionClosure: {})
      // create API client that will make all REST requests
      self.httpClient = LaravelConnectClient(settings: settings)

      // init Auth
      Auth.setup(laravelConnect:self)
    }
  

    public func execute(request: LaravelRequest) -> LaravelTask {
        let task = self.httpClient.buildLaravelTask(request: request)
        task.start()
        return task
    }
    
    public func list<T: NSManagedObject>(model: T.Type) -> ModelList{
        return ModelList(request: self.prepareConnectRequest(model: model))
    }
    
    private func prepareConnectRequest<T: NSManagedObject>(model: T.Type) -> LaravelRequest!
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
