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
    
    private static var instances: [String:LaravelConnect] = {
     return Dictionary<String,LaravelConnect>()
    }()
    
    // MARK: - Properties
    private var httpClient: LaravelConnectClient!
    private var settings: LaravelSettings!
    private var dataManager: CoreDataManager!
    
    private var presentersMap:Dictionary<String, ModelPresenter> = Dictionary()
    
    // MARK: - Methods

    /// Setup a named instance of LaravelConnect. A name can be passed to connect at the same time to more then one Laravel APP.
    ///
    /// - Parameters:
    ///   - name: name that identifies this instance. It can be left blank if only one instance is used
    ///   - settings: LaravelSettings, settings for the connection.
    ///   - onCompletion: bock that is called when the configuration is completed.
    public static func configure(name:String = "default", settings: LaravelSettings, onCompletion: @escaping (_:LaravelConnect) -> ()){
        self.instanceWithName(name:name).configure(settings:settings, onCompletion:onCompletion)
    }
    
    
    private static func instanceWithName(name:String) -> LaravelConnect{
        
        if let instance = instances[name] {
            return instance
        }
        
        let instance = LaravelConnect()
        instances[name]  = instance
        return instance
    }
    
    private func configure(settings : LaravelSettings, onCompletion: @escaping (_:LaravelConnect) -> ()){
        
        self.settings = settings
        self.dataManager = CoreDataManager(modelName: settings.coreDataModelName)
        
        self.dataManager.initCoreDataStack (completionClosure: {
            // create API client that will make all REST requests
            self.httpClient = LaravelConnectClient(settings:settings, coredata:self.dataManager)
            onCompletion(self)
        })

    }
    
    public static func shared() -> LaravelConnect {
        return instanceWithName(name: "default")
    }

    public func coreData() -> CoreDataManager {
        return self.dataManager;
    }

    public func get<T:ConnectModel>(relation: ConnectOneRelation<T>,
                    done:@escaping (NSManagedObjectID?, Error?) -> Void) -> LaravelTask {

        let request:LaravelRequest = self.httpClient.newOneRelationShow(relation: relation)
        
        request.start(success: { (response) in
            let r:LaravelSingleObjectModelResponse = response as! LaravelSingleObjectModelResponse
           if let objId = r.id,
                let obj = T.findWithId(in: self.coreData().viewContext, id: objId) {
                //refresh the relation
                relation.related = obj
            }
            done(r.managedId,nil)
        }) { (error) in
            done(nil,error)
        }
        return request
        
    }

    public func save(model: ConnectModel,
                    done:@escaping (NSManagedObjectID?, Error?) -> Void) -> LaravelTask {
        
        let request:LaravelRequest = self.httpClient.newModelSave(model: model)
        
        request.start(success: { (response) in
            let r:LaravelSingleObjectModelResponse = response as! LaravelSingleObjectModelResponse
            
            done(r.managedId,nil)
        }) { (error) in
            done(nil,error)
        }
        return request
    }
    
    public func get(model: ConnectModel.Type, modelId: ModelId,
                        include:[String] = [],
                        done:@escaping (NSManagedObjectID?, Error?) -> Void) -> LaravelTask {
        
        let request:LaravelRequest = self.httpClient.newModelShow(model: model, modelId: modelId, include: include)
        
        request.start(success: { (response) in
            let r:LaravelSingleObjectModelResponse = response as! LaravelSingleObjectModelResponse
            
            done(r.managedId,nil)
        }) { (error) in
            done(nil,error)
        }
        return request
    }
    
    public func list<T>(model: ConnectModel.Type, relation: ConnectManyRelation<T>?, filter: Filter = Filter(), include:[String] = []) -> ModelList {
        var entity = model.entity()
        if  let e = relation?.relatedType.entity() {
            entity = e
        }
        return ModelList(entity:entity,
                         request:self.httpClient.newModelList(model:model, relation:relation, include:include),
                         filter:filter)
    }
    
    private func pathForModel<T: NSManagedObject>(model: T.Type) -> String? {
        
        let entity = self.dataManager.entityDescriptionForClass(model:model, context:self.dataManager.viewContext)
        return entity?.modelPath
    }
    
 // MARK: - Debugging tools
    
    public static func storyBoard() -> UIStoryboard {
        
        let podBundle = Bundle(for: LaravelConnect.self)
        let bundleURL:URL = podBundle.url(forResource: "LaravelConnect", withExtension: "bundle")!
        let bundle = Bundle(url: bundleURL)
        
        return UIStoryboard(name: "modelBrowser", bundle: bundle)
        
    }
    

    public func presenterForClass(className: String) -> ModelPresenter {
        
        if let presenter = self.presentersMap[className] {
            return presenter
        }
        
        return DefaultPresenter()
    }
    
    public func presenterForClass(className: String, presenter:ModelPresenter) {
        self.presentersMap[className]  = presenter
    }
    
    
}
