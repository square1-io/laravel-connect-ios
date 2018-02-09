//
//  CoreDataDecoder.swift
//  FBSnapshotTestCase
//
//  Created by Roberto Prato on 01/02/2018.
//

import Foundation
import CoreData
import Square1CoreData

extension String: Error {}

extension String {
    
    var isNumeric: Bool {
        guard self.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self).isSubset(of: nums)
    }
    
    public func toDate() -> Date? {
        
        if(self.isNumeric) {
            let unixTimestamp = Double(self)!
            return Date(timeIntervalSince1970: unixTimestamp)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return  dateFormatter.date(from: self)
    }
    
    public func isDate() -> Bool {
        return self.compare("NSDate") == ComparisonResult.orderedSame
    }
    
}

public class CoreDataDecoder  {
    
    private let context: NSManagedObjectContext
    private let model: ConnectModel.Type
    private let entity: NSEntityDescription
    public var ids: Array<ModelId>
    public var managedIds: Array<NSManagedObjectID>
    
    //if no entity throws
    public init(context:NSManagedObjectContext, model:ConnectModel.Type) throws {
        self.context = context
        self.model = model
        self.ids = Array<Int64>()
        self.managedIds = Array<NSManagedObjectID>()
        self.entity = NSEntityDescription.entity(forEntityName:NSStringFromClass(model), in:self.context)!
    }
    
    private func entityDescription(model: NSManagedObject.Type) throws -> NSEntityDescription {
        return try self.entityDescription(className:NSStringFromClass(model))
    }
    
    private func entityDescription(className: String) throws -> NSEntityDescription {
        
        if let entity = NSEntityDescription.entity(forEntityName:className, in:self.context) {
            return entity
        }else {
            throw "Invalid Entity"
        }
    }
    
    public func decode(items:Array<[String: AnyObject]>)  {
        
        for item in items {
            do{
                var id:ModelId = 0
                let obj = try self.decode(item: item, model: self.model, id:&id)
                self.ids.append(id)
                self.managedIds.append(obj.objectID)
            }catch {}
        }
    }
    
    public func decode(item:[String : AnyObject], model:ConnectModel.Type, id:inout ModelId) throws -> ConnectModel {
        
        let entity:NSEntityDescription = try self.entityDescription(model:model)
        return try self.decode(item: item, entity: entity, id: &id)
        
    }
    
    public func decode(item:[String : AnyObject], entity:NSEntityDescription, id:inout ModelId) throws -> ConnectModel {

        id = item["id"] as! ModelId
 #if DEBUG
    print("START decoding ---> \(String(describing: entity.name!)) \(String(describing: entity.managedObjectClassName!)) id = \(id)")
#endif
        let predicate = NSPredicate(format: "id == %@", String(describing:id))
        let currentModel = NSClassFromString(entity.managedObjectClassName) as! ConnectModel.Type
        let object = currentModel.findOrCreate(in: self.context, matching: predicate, configure: {_ in () })
        
        let attributes = entity.attributesByName
        
        // build a map between the jsonKey and the name of the corresponding member
        var mapJsonKeyToAttributeName = Dictionary<String,String>()
        
        for (name, attribute) in attributes {
            mapJsonKeyToAttributeName[name] = attribute.name
            guard let value = self.parseValue(value: item[attribute.jsonKey], attribute: attribute) else {
                continue
            }
#if DEBUG
    print("setting ---> \(name) = \(value)")
#endif
            object.setValue(value, forKey:name)
        }
        
        if let oneRelations = object.connectRelations {
            for (_,oneRelation) in oneRelations {
                try oneRelation.decode(decoder: self, parentJson: item)
            }
        }
        
        let relations = entity.relationshipsByName
        
        for (name, relation) in relations {
            
            if(relation.isToMany){
                //deal with it
            }else {
#if DEBUG
    print("decoding single relation ---> \(name)")
#endif
                // here we have a relations
                guard let relationData:[String : AnyObject] = item[name] as? [String : AnyObject] else { continue}
                var currentId:ModelId = 0
                let relationObject = try self.decode(item: relationData, entity: relation.destinationEntity!, id:&currentId)
                object.setValue(relationObject, forKey:name)
            }
        }
#if DEBUG
    print("END decoding ---> \(String(describing: entity.name!)) id = \(id)")
 #endif
        return object
    }
    
    private func parseValue(value:Any?, attribute:NSAttributeDescription) -> Any? {
        
        let className = attribute.attributeValueClassName
     
        
        switch value {
            
        case let isNull as NSNull:
            return nil
            
        case let stringValue as String:
            if(className?.isDate())! {
                return stringValue.toDate()
            }
            return stringValue
            break
            
        case .none: break
        case .some(_): break
        }
        
        return value
    }
}
