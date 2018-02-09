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
    
    public func decode(decoder:CoreDataDecoder, parentJson:[String: AnyObject]) throws {}
}
protocol ConnectOneRelationProtocol {
    

    
    var relatedId: ModelId? {get}
    var relatedModel:ConnectModel.Type {get}
    var name:String {get}
    
    func object() -> ConnectModel?
    
}
open class ConnectOneRelation<T: ConnectModel> : ConnectRelation, ConnectOneRelationProtocol {
    
    typealias K  = T
    //the Managed Object for this relation if one is set
    var related: T? {
        set {
            self.parent.setValue(newValue, forKey: self.name)
        }
        get {
            return  self.parent.value(forKey: self.name) as? T
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
                break
            }
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
    
    private func getRelatedId() -> ModelId? {
        
        //is the full related object available?
        if self.related != nil,
            self.related?.primaryKey != nil {
            return self.related?.primaryKey
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
        
        
        ///set the relation foign key value
        if let relatedId = parentJson[self.jsonForeignKey],
            let cdProperty = self.coreDataForeignKey,
            cdProperty.isEmpty == false {
            self.parent.setValue(relatedId, forKey: cdProperty)
        }
        
        // parse the relation json if it was included
        if let data = parentJson[self.jsonKey] as? [String: AnyObject],
            let entity = self.relationDescription.destinationEntity{
            var newId:ModelId = 0
            let relatedObject = try decoder.decode(item: data, entity: entity, id: &newId)
            self.related = relatedObject as! T
        }

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
