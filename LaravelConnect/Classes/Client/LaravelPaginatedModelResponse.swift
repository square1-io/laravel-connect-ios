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
    
    public private(set) var ids: Array<Int64> = Array()
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
        
    }
}
