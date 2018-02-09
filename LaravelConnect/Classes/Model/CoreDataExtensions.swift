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

//the name of the CoreData property that acts ad the primary key for this entity
let CONST_LARAVEL_COREDATA_PRIMARY_KEY = "laravel.cd.primary.key"

let CONST_LARAVEL_MODEL_PATH_KEY = "laravel.model.path"

public typealias ModelId = Int64

extension NSEntityDescription {
    
    var modelPath : String {return  self.userInfo?[CONST_LARAVEL_MODEL_PATH_KEY] as! String}
    
    var primaryKeyName: String { return self.userInfo?[CONST_LARAVEL_COREDATA_PRIMARY_KEY] as! String }
    
    public var oneRelations:[String : NSRelationshipDescription] {
        
        get {
            return  self.relationshipsByName.filter({ item in
                 item.value.isToMany == false
            })
        }
    }
    
    public var manyRelations:[String : NSRelationshipDescription] {
        
        get {
            return  self.relationshipsByName.filter({ item in
                item.value.isToMany == true
            })
        }
    }
}

extension NSPropertyDescription {
    
    var jsonKey: String { return self.userInfo?[CONST_LARAVEL_JSON_KEY] as! String }
    
}

extension NSRelationshipDescription {
    // this is inherited from the NSPropertyDescription entity
    //var jsonKey: String { return self.userInfo?["laravel.json.key"] as! String }
    
    var jsonForeignKey: String { return self.userInfo?[CONST_LARAVEL_JSON_FOREIGN_KEY] as! String }
}



open class ConnectModel: NSManagedObject, Managed {
    
    open override func awakeFromInsert() {
        super.awakeFromInsert()
        mapProperties()
        setupRelations()
    }
    
    open override func awakeFromFetch() {
        super.awakeFromFetch()
        mapProperties()
        setupRelations()
    }
    
    open func setupRelations() {
        
    }
    
    private func mapProperties(){
        
        var map = Dictionary<String, NSPropertyDescription>()
        
        for p in self.entity.properties {
            map[p.jsonKey] = p
        }
        
        self.jsonKeyToProperty = map
    }
    
    private var jsonKeyToProperty:Dictionary<String, NSPropertyDescription>?
    
    public func properyByJsonKey(jsonKey:String) -> NSPropertyDescription? {
        
        if let p = self.jsonKeyToProperty {
            return p[jsonKey]
        }
        return nil
    }
 
    public var modelPath:String {
        get {
            return self.entity.modelPath
        }
    }
    
    /*
     All properties that are not relations
    */
    public var attributes:[String : NSAttributeDescription] {

        get {
           return  self.entity.attributesByName
        }
    }
    
    /*
      The value of the primary key for this instance
     */
    public var primaryKey: ModelId {
        
        get {
            //get the name of the property first
            let propertyName = self.entity.primaryKeyName
            if  self.attributes[propertyName] != nil,
                let modelId = self.value(forKey: propertyName) as? ModelId  {
                return modelId
            }
            return 0
        }
        
    }
    
    public var oneRelations:[String : NSRelationshipDescription] {
    
        get {
            return  self.entity.oneRelations
        }
    }
    
    public var manyRelations:[String : NSRelationshipDescription] {
        
        get {
            return  self.entity.manyRelations
        }
    }
    
    public private(set) var connectRelations:Dictionary<String, ConnectRelation>?
    
    static func findWithId(in context: NSManagedObjectContext, id:ModelId) -> Self? {
        let predicate = NSPredicate(format: self.entity().primaryKeyName + " == %i",id)
        return self.findOrFetch(in: context, matching: predicate )
    }

    
    public func setupRelation<T:ConnectRelation>(name:String) -> T {
        
        if(self.connectRelations == nil){
            self.connectRelations = Dictionary()
        }
        
        let relations:[String : NSRelationshipDescription] = self.entity.relationshipsByName
        let relation = T(parent: self, description:relations[name]!)
        self.connectRelations![name] = relation
        return relation
        
    }
    
    public func refresh(include:[String] = [], done:@escaping (NSManagedObjectID?, Error?) -> Void) -> LaravelTask {
        return LaravelConnect.shared().get(model:type(of: self), modelId: self.primaryKey, include:include, done: done)
    }

    public static func get(modelId: ModelId, include:[String] = [], done:@escaping (NSManagedObjectID?, Error?) -> Void) -> LaravelTask {
        return LaravelConnect.shared().get(model:self, modelId: modelId, include:include, done: done)
    }
    
    public static func list(filter: Filter = Filter(), include:[String] = []) -> ModelList {
        return LaravelConnect.shared().list(model:self, relation:nil, filter:filter, include:include)
    }
}

public extension Array {
    public func toDictionary<Key: Hashable>(with selectKey: (Element) -> Key) -> [Key:Element] {
        var dict = [Key:Element]()
        for element in self {
            dict[selectKey(element)] = element
        }
        return dict
    }
}

extension NSManagedObjectContext {
    
    public func fetch<T:NSManagedObject>(ids:Array<Int64>, entityName:String) throws -> [T]  {
     
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetch.predicate =  NSPredicate(format: "id IN %@", ids)
        let objects = try self.fetch(fetch) as! [T]
        return objects
    }
    
}

extension Data {
    
    public func toJSON() -> Dictionary<String,Any>  {
        do{
            let json: Dictionary<String,Any> = try JSONSerialization.jsonObject(with: self, options: .allowFragments) as! Dictionary
            return json
        } catch let _ as NSError {
            return Dictionary()
        }
    }
    
}




