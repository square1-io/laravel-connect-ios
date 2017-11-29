//
//  File.swift
//  test
//
//  Created by Roberto Prato on 28/11/2017.
//  Copyright © 2017 Roberto Prato. All rights reserved.
//

import Foundation
import CoreData

let CONST_LARAVEL_JSON_KEY = "laravel.json.key"
let CONST_LARAVEL_JSON_FOREIGN_KEY = "laravel.model.foreignKey"
let CONST_LARAVEL_JSON_PRIMARY_KEY = "laravel.json.primary.key"


extension NSManagedObject {
    
    func refresh(observer: Any<Observer>) -> <#return type#> {
        return LaravelConnect.refresh(self, observer);
    }
    
    func delete(observer: Any<Observer>)
    
    static func list(){
        return LaravelConnect.refresh([self modelPath], observer);
    }
}

extension NSEntityDescription {
    
    var jsonPrimaryKey: String { return self.userInfo?[CONST_LARAVEL_JSON_PRIMARY_KEY] as! String }
}

extension NSPropertyDescription {
    
    var jsonKey: String { return self.userInfo?[CONST_LARAVEL_JSON_KEY] as! String }
    
}

extension NSRelationshipDescription {
    // this is inherited from the NSPropertyDescription entity
    //var jsonKey: String { return self.userInfo?["laravel.json.key"] as! String }
    
    var jsonForeignKey: String { return self.userInfo?[CONST_LARAVEL_JSON_FOREIGN_KEY] as! String }
}


public class LaravelModelFactory {
    
    public static func parseJson (json:[String:AnyObject], entityType:String, context:NSManagedObjectContext) -> NSManagedObject? {
        let entityDescription = NSEntityDescription.entity(forEntityName: entityType, in: context);
        return self.parseJson(json:json, entityType:entityType, context:context)
    }
    public static func parseJson (json:[String:AnyObject], entityDescription:NSEntityDescription, context:NSManagedObjectContext) -> NSManagedObject? {
        //check if object is available in coreData already:
        let uniqueKey = json[(entityDescription?.jsonPrimaryKey)!] as! NSNumber;
        let currentObject : NSManagedObject? = nil ; // fetch by uniqueKey context.fetch(<#T##request: NSFetchRequest<NSFetchRequestResult>##NSFetchRequest<NSFetchRequestResult>#>)
        
        if(currentObject == nil){
            /// create one
        }
        
        let properties = entityDescription?.propertiesByName as! [String : NSPropertyDescription]
        for (name, property) in properties {
            let value = json[property.jsonKey]
            currentObject?.setValue(value, forKey: name)
        }
        
        //do the same on relationships
        let relations = entityDescription?.relationshipsByName as! [String : NSRelationshipDescription]
        for (name, relation) in relations {
            let value = json[relation.jsonKey]
            if(relation.isToMany == NO){
                
                // check if I have the full json ?
                if(json[relation.jsonKey]){
                    
                }else if(json[relation.jsonForeignKey]) {
                    //
                    
                }
                
                let relatedObject = self.parseJson(json: value, entityDescription:relation.destinationEntity, context:context)
                currentObject?.setValue(value, forKey: name)
            }
            
        }
        
        return currentObject;
    }
    
}


