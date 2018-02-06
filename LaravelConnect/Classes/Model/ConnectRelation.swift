//
//  ConnectRelation.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 02/02/2018.
//

import Foundation
import CoreData

open class ConnectRelation : NSObject {
    
    //the key that identify this relation in the received json
    public var jsonKey:String {
        get {
            return relationDescription.jsonKey
        }
    }
    
    //the name of the property in the CoreData model for this relation
    public var name:String {
        get {
            return relationDescription.name
        }
    }
    
    public var parentModel:ConnectModel.Type {
        
        get {
            return type(of: self.parent)
        }
    }
    
    public var relatedModel:ConnectModel.Type {
        
        get {
            return NSClassFromString((self.relationDescription.destinationEntity?.managedObjectClassName)!) as! ConnectModel.Type
        }
    }
    
    let relationDescription: NSRelationshipDescription
    //the parent ManagedObject that owns this relation
    let parent: ConnectModel
    
    required public init(parent:ConnectModel, description:NSRelationshipDescription){
        self.parent = parent
        self.relationDescription = description
    }
}
protocol ConnectOneRelationProtocol {
    
    var relatedId: Any? {get}
    var relatedModel:ConnectModel.Type {get}
    
}
open class ConnectOneRelation<T: ConnectModel> : ConnectRelation, ConnectOneRelationProtocol {
    
    //the Managed Object for this relation if one is set
    var related: T?
    
    // the json foreign key in case the model is not set
    public var jsonForeignKey:String {
        get {
            return relationDescription.jsonForeignKey
        }
    }
    
    //we might not have the object but just the foreign key
    public var relatedId: Any? {
        
        get {
            return getRelatedId()
        }
    }
    
    public required init(parent:ConnectModel,
                description:NSRelationshipDescription){
        super.init(parent:parent, description: description)
        
    }
    
    public func object() -> T! {
        return self.parent.value(forKey: self.name) as! T
    }
    
    private func getRelatedId() -> Any? {
        
        //is the full related object available?
        if self.related != nil,
            self.related?.primaryKey != nil {
            return self.related?.primaryKey
        }
        //try the foreign key if set on the parent object
        if let p = self.parent.properyByJsonKey(jsonKey: self.jsonForeignKey) {
            return self.parent.value(forKey: p.name)
        }
        
        return nil
    }

    /*
     
     */
    public func decode(decoder:CoreDataDecoder, parentJson:[String: AnyObject]) throws {
        
//        //if there is no json for the object try extracting at least the id of the related one
//        guard let data = parentJson[self.jsonKey] as? [String: AnyObject],
//        let entity = self.relationDescription.destinationEntity else {
//            
//            guard let relatedId = parentJson[self.jsonForeignKey] as? Int64 else {
//                self.relatedId = self.related?.value(forKey: self.jsonForeignKey) as! Int64
//                return
//            }
//            
//            self.relatedId = relatedId
//            
//            return;
//        }
//        
//        self.related = try decoder.decode(item:data,
//                                      entity:entity,
//                                      id:&self.relatedId) as? T
//        
    }
    
}

public class ConnectManyRelation<T: ConnectModel> : ConnectRelation {
    
    private var related: Set<T>
    
    public required init(parent: ConnectModel,
                         description: NSRelationshipDescription){
        
        self.related = Set()
        super.init(parent:parent, description: description)
        
    }
    
    public func list(filter: Filter = Filter(), include:[String] = []) -> ModelList {
        return LaravelConnect.shared().list(model:self.parentModel, relation:self, filter:filter, include:include)
    }
    
    /*
     
    */
//    public func decode(decoder:CoreDataDecoder, parentJson:[String: AnyObject]) {
//
//        //if there is no json for the object try extracting at least the key
//        guard let item[self.jsonKey] else {
//
//        }
//
//    }
    
}
