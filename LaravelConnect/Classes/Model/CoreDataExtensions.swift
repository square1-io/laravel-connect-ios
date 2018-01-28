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
//  Created by Roberto Prato on 28/11/2017.
//

import Foundation
import CoreData
import Square1CoreData

let CONST_LARAVEL_JSON_KEY = "laravel.json.key"
let CONST_LARAVEL_JSON_FOREIGN_KEY = "laravel.model.foreignKey"
let CONST_LARAVEL_JSON_PRIMARY_KEY = "laravel.json.primary.key"
let CONST_LARAVEL_MODEL_PATH_KEY = "laravel.model.path"


extension NSManagedObject  {
    
    public static func list(filter: Filter = Filter()) -> ModelList {
        return LaravelConnect.shared().list(model: self, relation: "", filter: filter)
    }
}

extension NSEntityDescription {
    
    var modelPath : String {return  self.userInfo?[CONST_LARAVEL_MODEL_PATH_KEY] as! String}
    
    var jsonPrimaryKey: String { return String(describing:self.userInfo?[CONST_LARAVEL_JSON_PRIMARY_KEY]) }
}

extension NSPropertyDescription {
    
    var jsonKey: String { return self.userInfo?[CONST_LARAVEL_JSON_KEY] as! String }
    
}

extension NSRelationshipDescription {
    // this is inherited from the NSPropertyDescription entity
    //var jsonKey: String { return self.userInfo?["laravel.json.key"] as! String }
    
    var jsonForeignKey: String { return self.userInfo?[CONST_LARAVEL_JSON_FOREIGN_KEY] as! String }
}


extension SQ1CoreDataManager {
 
    public func entityDescriptionForClass(model: NSManagedObject.Type, context: NSManagedObjectContext) -> NSEntityDescription? {
        return self.entityDescription(entityName: NSStringFromClass(model) , context: context)
    }
    
    public func entityDescription(entityName: String, context: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: entityName, in: context)
    }
    
    public func pathForModel(model: NSManagedObject.Type) -> String {
        let entity = self.entityDescriptionForClass(model: model, context: self.viewContext)
        if let entity = entity {
            return entity.modelPath
        }
        return ""
    }
    
}

public class LaravelModelFactory {
    
    public static func parseJson (json:[String:AnyObject], entityType:String, context:NSManagedObjectContext) -> NSManagedObject? {
        let entityDescription = NSEntityDescription.entity(forEntityName: entityType, in: context);
        return self.parseJson(json:json, entityType:entityType, context:context)
    }
    public static func parseJson (json:[String:AnyObject], entityDescription:NSEntityDescription, context:NSManagedObjectContext) -> NSManagedObject? {
        //check if object is available in coreData already:
        let uniqueKey = json[(entityDescription.jsonPrimaryKey)] as! NSNumber;
        let currentObject : NSManagedObject? = nil ; // fetch by uniqueKey context.fetch(<#T##request: NSFetchRequest<NSFetchRequestResult>##NSFetchRequest<NSFetchRequestResult>#>)
        
        if(currentObject == nil){
            /// create one
        }
        
        let properties = entityDescription.propertiesByName as! [String : NSPropertyDescription]
        for (name, property) in properties {
            let value = json[property.jsonKey]
            currentObject?.setValue(value, forKey:name)
        }
        
        //do the same on relationships
        let relations = entityDescription.relationshipsByName as! [String : NSRelationshipDescription]
        for (name, relation) in relations {
            let value = json[relation.jsonKey]
            if(relation.isToMany == false){
                
                // check if I have the full json ?
                if((json[relation.jsonKey]) != nil){
                    
                }else if((json[relation.jsonForeignKey]) != nil) {
                    //
                    
                }
                
                let relatedObject = self.parseJson(json: value as! [String : AnyObject], entityDescription:relation.destinationEntity!, context:context)
                currentObject?.setValue(value, forKey: name)
            }
            
        }
        
        return currentObject;
    }
    
}


