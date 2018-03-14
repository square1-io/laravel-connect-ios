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
        self.entity = model.entity()
    }
    
    private func entityDescription(model: NSManagedObject.Type) throws -> NSEntityDescription {
        return model.entity()
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
    
    public func findOrCreate(entity:NSEntityDescription, id:ModelId) throws -> ConnectModel {
        
        let predicate = NSPredicate(format: entity.primaryKeyName + " == %i",id)
        let currentModel = NSClassFromString(entity.managedObjectClassName) as! ConnectModel.Type
        let object = currentModel.findOrCreate(in: self.context, matching: predicate, configure: {_ in () })
        object.primaryKeyValue = id
        return object
    }
    public func decode(item:[String : AnyObject], entity:NSEntityDescription, id:inout ModelId) throws -> ConnectModel {

        id = item[entity.primaryKeyJsonKey] as! ModelId
        
#if DEBUG
    print("START decoding ---> \(String(describing: entity.name!)) \(String(describing: entity.managedObjectClassName!)) id = \(id)")
#endif
        let predicate = NSPredicate(format: entity.primaryKeyName + " == %i",id)
        let currentModel = NSClassFromString(entity.managedObjectClassName) as! ConnectModel.Type
        let object = currentModel.findOrCreate(in: self.context, matching: predicate, configure: {_ in () })
        
        let attributes = entity.attributesByName
        
        for (name, attribute) in attributes {
            guard let value = self.parseValue(value: item[attribute.jsonKey], attribute: attribute) else {
                continue
            }
#if DEBUG
    print("setting ---> \(name) = \(value)")
#endif
            object.setValue(value, forKey:name)
        }
        
        object.setValue(true, forKey: "hasData")
        
        if let oneRelations = object.connectRelations {
            for (_,oneRelation) in oneRelations { 
                try oneRelation.decode(decoder: self, parentJson: item)
            }
        }
        
#if DEBUG
    print("END decoding ---> \(String(describing: entity.name!)) id = \(id)")
 #endif
        return object
    }
    
    
    private func parseValue(value:Any?, attribute:NSAttributeDescription) -> Any? {
     
        let attributeType:NSAttributeType = attribute.attributeType
        let valueTransformerName = attribute.valueTransformerName
        
        // We have UploadedImage
        if let valueTransformerName = valueTransformerName, "UploadedImageCoreDataTransformer".elementsEqual(valueTransformerName){
            if let url:String = value as? String {
                return UploadedImage(string: url)
            }else {
                return UploadedImage(string: nil)
            }
        }
        
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
