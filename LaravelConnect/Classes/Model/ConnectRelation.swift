//
//  ConnectRelation.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 02/02/2018.
//

import Foundation
import CoreData

public protocol ConnectRelationProtocol {
    
    var jsonKey:String {get}
    var name:String {get}
    var parent: ConnectModel {get}
    var parentType:ConnectModel.Type {get}
    var relatedType:ConnectModel.Type {get}
    func decode(decoder:CoreDataDecoder, parentJson:[String: AnyObject]) throws
}

open class ConnectRelation<T: ConnectModel> : ConnectRelationProtocol {
    
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
    
    public var parentType:ConnectModel.Type {
        
        get {
            return type(of: self.parent)
        }
    }
    
    public var relatedType:ConnectModel.Type {
        
        get {
            return NSClassFromString((self.relationDescription.destinationEntity?.managedObjectClassName)!) as! ConnectModel.Type
        }
    }
    

    
    let relationDescription: NSRelationshipDescription
    //the parent ManagedObject that owns this relation
    public let parent: ConnectModel
    
    required public init(parent:ConnectModel, description:NSRelationshipDescription){
        self.parent = parent
        self.relationDescription = description
    }
    
    public func decode(decoder:CoreDataDecoder, parentJson:[String: AnyObject]) throws {}
}
protocol ConnectOneRelationProtocol : ConnectRelationProtocol {
    
    var relatedId: ModelId? {get}

    func object() -> ConnectModel?
    func setObject(object:ConnectModel)
    
    func refresh(done:@escaping (NSManagedObjectID?, Error?) -> Void) -> LaravelTask
    
}
open class ConnectOneRelation<T> : ConnectRelation<T>, ConnectOneRelationProtocol where T : ConnectModel {
    
 
    //the Managed Object for this relation if one is set
    var related: T? {
        set {
            self.parent.setValue(newValue, forKey: self.name)
        }
        get {
            return self.parent.value(forKey: self.name) as? T
        }
    }
    
    // the json foreign key in case the model is not set
    public var jsonForeignKey:String {
        get {
            return relationDescription.jsonForeignKey
        }
    }
    
    // the name of the property in the parent model that stores the  foreign key
     var coreDataForeignKey:String?
    
    //we might not have the object but just the foreign key
    public var relatedId: ModelId? {
        
        get {
            return getRelatedId()
        }
    }
    
    public required init(parent:ConnectModel,
                description:NSRelationshipDescription){
        super.init(parent:parent, description: description)
        
        //this should be changed
        let attributes = parent.attributes
        
        // build a map between the jsonKey and the name of the corresponding member
        for (name, attribute) in attributes {
            if(self.jsonForeignKey.elementsEqual(attribute.jsonKey)) {
                self.coreDataForeignKey = name
                //we exclude the foreigh key for the list of editable fields.
                self.parent.setNonEditable(field: name)
                break
            }
        }
    }
    

    public func setObject(object: ConnectModel) {
        
        if let object:T = object as? T {
            self.related = object
        }
    }
    public func object() -> ConnectModel? {
        
        //if it is set then return it
        if self.related != nil {
            return self.related
        }
        // lets see if instead it is available in CoreData already
        if let modelId = self.getRelatedId() {
            self.related =  T.findWithId(in:self.parent.managedObjectContext!, id:modelId )
            do {
                try self.parent.managedObjectContext?.save()
            } catch {}
        }
        
        return self.related
    }
    
    public func refresh(done:@escaping (NSManagedObjectID?, Error?) -> Void) -> LaravelTask {
        return LaravelConnect.shared().get(relation:self, done: done)
    }
    
    private func getRelatedId() -> ModelId? {
        
        //is the full related object available?
        if self.related != nil,
            self.related?.primaryKeyValue != nil {
            return self.related?.primaryKeyValue
        }
        //try the foreign key if set on the parent object
        if let p = self.parent.properyByJsonKey(jsonKey: self.jsonForeignKey) {
            return self.parent.value(forKey: p.name) as? ModelId
        }
        
        return nil
    }

    /*
     
     */
    public override func decode(decoder:CoreDataDecoder, parentJson:[String: AnyObject]) throws {
#if DEBUG
    print("decoding single relation ---> \(self.name)")
#endif
        ///set the relation foign key value
        if let relatedId = parentJson[self.jsonForeignKey],
            let cdProperty = self.coreDataForeignKey,
            cdProperty.isEmpty == false {
            self.parent.setValue(relatedId, forKey: cdProperty)
        }
        
        // parse the relation json if it was included
        if let data = parentJson[self.jsonKey] as? [String: AnyObject],
            let entity = self.relationDescription.destinationEntity {
            var newId:ModelId = 0
            let relatedObject = try decoder.decode(item: data, entity: entity, id: &newId)
            self.related = relatedObject as! T
        }
        // if the json for the related object was not passed but if we have the foreign key we create
        // an empty coreData object
        else if let relatedId = parentJson[self.jsonForeignKey] as? ModelId,
            let entity = self.relationDescription.destinationEntity {
            self.related = try decoder.findOrCreate(entity:entity, id:relatedId)  as! T
        }

    }
    
}

public protocol ConnectManyRelationProtocol : ConnectRelationProtocol {
    
    func list() -> ModelList
    func localList() -> NSSet
    func list(filter: Filter , include:[String] ) -> ModelList
}

public class ConnectManyRelation<T: ConnectModel> : ConnectRelation<T>, ConnectManyRelationProtocol {
    
    private var set:NSMutableSet!
    
    public required init(parent: ConnectModel,
                         description: NSRelationshipDescription){
        super.init(parent:parent, description: description)
        self.set = parent.mutableSetValue(forKey: self.name)
    }
    
    public func localList() -> NSSet {
        return self.set
    }
    
    public func list() -> ModelList {
        
        return LaravelConnect.shared()
            .list(model:self.parentType, relation:self)
        
    }
    public func list(filter: Filter = Filter(), include:[String] = []) -> ModelList {
        return LaravelConnect.shared().list(model:self.parentType, relation:self, filter:filter, include:include)
    }
    
    open var description : String {
        return "\((self.name)) \(self.relatedType)"
    }
    
     open var debugDescription : String {
        return "\(self.name) \(self.relatedType)"
    }

}
