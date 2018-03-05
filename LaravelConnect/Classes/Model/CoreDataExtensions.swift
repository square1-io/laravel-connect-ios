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
let CONST_MODEL_ID_UNSET:ModelId = 0

extension NSEntityDescription {
    
    var modelPath : String {return  self.userInfo?[CONST_LARAVEL_MODEL_PATH_KEY] as! String}
    
    
    /// Coredata property name for the primary key
    var primaryKeyName: String { return self.userInfo?[CONST_LARAVEL_COREDATA_PRIMARY_KEY] as! String }
    
    /// Json key for the primary key
    var primaryKeyJsonKey: String {
        
        if let attribute:NSAttributeDescription = self.attributesByName[self.primaryKeyName] {
            return attribute.jsonKey
        }
        return "id"
    }
    
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
    
    var jsonKey: String {
        if let uInfo = self.userInfo,
            let k = uInfo[CONST_LARAVEL_JSON_KEY] {
            return k as! String
        }
        return "" }
    
}

extension NSRelationshipDescription {
    // this is inherited from the NSPropertyDescription entity
    //var jsonKey: String { return self.userInfo?["laravel.json.key"] as! String }
    
    var jsonForeignKey: String { return self.userInfo?[CONST_LARAVEL_JSON_FOREIGN_KEY] as! String }
}



public extension Array {
    
    /*
     
    */
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
    
    public func toJSON() -> Dictionary<String,AnyObject>  {
        do{
            let json: Dictionary<String,AnyObject> = try JSONSerialization.jsonObject(with: self, options: .allowFragments) as! Dictionary
            return json
        } catch let error as NSError {
#if DEBUG
    print(error)
#endif
        return Dictionary()
        }
    }
    
}




