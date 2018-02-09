//
//  LaravelPaginatedModelResponse.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 31/01/2018.
//

import Foundation

import Foundation
import Square1CoreData
import Square1Network
import CoreData


public class LaravelPaginatedModelResponse: LaravelPaginatedResponse {
    
    public private(set) var ids: Array<ModelId> = Array()
    public private(set) var managedIds: Array<NSManagedObjectID> = Array()
    
    private var items: Array<[String : AnyObject]>?
    
    public required init(with dictionary: [String : Any]) {
       super.init(with: dictionary)

       self.items = self.data["items"] as! Array<[String : AnyObject]>
      
    }
    
    
    func storeModelObjects(coreData: CoreDataManager, model: ConnectModel.Type) throws {
        let context = coreData.newBackgroundContext()
        let decoder = try CoreDataDecoder(context:context, model:model)
        decoder.decode(items: self.items!)
        try context.save()
        self.ids.append(contentsOf: decoder.ids)
        self.managedIds.append(contentsOf: decoder.managedIds)
        
    }
}

public class LaravelSingleObjectModelResponse: LaravelPaginatedModelResponse {
    
    public var id:Any? {
        
        get {
            guard self.ids.count > 0 else {return nil}
            return self.ids.first
        }
    }
    
    public var managedId:NSManagedObjectID? {
        get {
            guard self.managedIds.count > 0 else {return nil}
            return self.managedIds.first
        }
    }
    
    
}
