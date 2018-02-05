//
//  ConnectRelation.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 02/02/2018.
//

import Foundation
import CoreData

open class ConnectRelation : NSObject {
    
    public var jsonKey:String {
        get {
            return relationDescription.jsonKey
        }
    }
    
    public var jsonForeignKey:String {
        get {
            return relationDescription.jsonForeignKey
        }
    }
    
    public var name:String {
        get {
            return relationDescription.name
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

open class ConnectOneRelation<T: ConnectModel> : ConnectRelation {
    
    //the Managed Object for this relation if one is set
    var related: T?
    //we might not have the object but just the foreign key
    private var relatedId: Int64
    
    public required init(parent:ConnectModel,
                description:NSRelationshipDescription){
        self.relatedId = 0
        super.init(parent:parent, description: description)
        
    }
    
    public func object() -> T! {
        return self.parent.value(forKey: self.name) as! T
    }

    /*
     
     */
    public func decode(decoder:CoreDataDecoder, parentJson:[String: AnyObject]) throws {
        
        //if there is no json for the object try extracting at least the id of the related one
        guard let data = parentJson[self.jsonKey] as? [String: AnyObject],
        let entity = self.relationDescription.destinationEntity else {
            
            guard let relatedId = parentJson[self.jsonForeignKey] as? Int64 else {
                self.relatedId = self.related?.value(forKey: self.jsonForeignKey) as! Int64
                return
            }
            
            self.relatedId = relatedId
            
            return;
        }
        
        self.related = try decoder.decode(item:data,
                                      entity:entity,
                                      id:&self.relatedId) as? T
        
    }
    
}

public class ConnectManyRelation<T: ConnectModel> : ConnectRelation {
    
    private var related: Set<T>
    
    public required init(parent: ConnectModel,
                         description: NSRelationshipDescription){
        
        self.related = Set()
        super.init(parent:parent, description: description)
        
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
