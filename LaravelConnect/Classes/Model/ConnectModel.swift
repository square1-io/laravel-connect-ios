// Copyright © 2018 Square1.
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
//  Created by Roberto Prato on 09/02/2018.
//

import CoreData
import Foundation
import Square1CoreData

public protocol ModelPresenter {
    
    func modelTitle(model:ConnectModel) -> String
    func modelSubtitle(model:ConnectModel) -> String
    
}

open class DefaultPresenter : ModelPresenter {
    
    public func modelTitle(model:ConnectModel) -> String {
        if let nameP = model.attributes["name"] {
            if let name:Any = model.value(forKey: nameP.name) {
                return String(describing:name)
            }
        }
        return "\(type(of: model)) \(model.primaryKeyValue)"
    }
    
    public func modelSubtitle(model:ConnectModel) -> String {
        return ""
    }
    
}


/// The base class for all Model Classes. It extends
/// NSManagedObject and adds options to pull and sych instances with the
// backend
open class ConnectModel: NSManagedObject, Managed {
    
    open override func awakeFromInsert() {
        super.awakeFromInsert()
        initialize()
        mapProperties()
        setupRelations()
    }
    
    open override func awakeFromFetch() {
        super.awakeFromFetch()
        initialize()
        mapProperties()
        setupRelations()
    }
    
    open func setupRelations() {
        
    }
    
    private var nonEditableFields:Array<String>!
    
    private func initialize(){
        
        self.nonEditableFields = Array()
        
        self.nonEditableFields.append("hasData")
        self.nonEditableFields.append("createdAt")
        self.nonEditableFields.append("updatedAt")
        self.nonEditableFields.append(self.primaryKeyName)
    }
    
    func setNonEditable(field:String){
        self.nonEditableFields.append(field)
    }
    
    private func mapProperties(){
        
        var map = Dictionary<String, NSPropertyDescription>()
        
        for p in self.entity.properties {
            map[p.jsonKey] = p
        }
        
        self.jsonKeyToProperty = map
    }
    
    // stores properties for this entities in a dictionay keyed with the name of the
    // corresponding json field
    private var jsonKeyToProperty:Dictionary<String, NSPropertyDescription>?
    
    
    /// Returns a property description given the associated json key
    ///
    /// - Parameter jsonKey: String key value in the json data dictionary for this parameter
    /// - Returns: NSPropertyDescription the Core Data property description associated to this json key.
    public func properyByJsonKey(jsonKey:String) -> NSPropertyDescription? {
        
        if let p = self.jsonKeyToProperty {
            return p[jsonKey]
        }
        return nil
    }
    
    
    /// The root path in the laravel connect API that gives access to this Model Class CRUD operations
    public var modelPath:String {
        get {
            return self.entity.modelPath
        }
    }
    
    
    /// shortcut to get the CoreData class / entity name
    public var className:String {
        get {
            return self.entity.name!
        }
    }
    

    /// Dictionary name and NSAttributeDescription of the properties for this object that are not relations
    public var attributes:[String : NSAttributeDescription] {
        
        get {
            return self.entity.attributesByName
        }
    }
    
    
    /// Dictionaty with attributes that are editable, this doesn't include foreign keys and other values
    /// specified in the nonEditableFields
    public var editableAttributes:[String : NSAttributeDescription] {
        
        var editableAttributes = self.attributes
        for (key) in self.nonEditableFields {
            editableAttributes.removeValue(forKey: key)
        }
        
        return editableAttributes
    }


    /// the value of the primary key for this object instance
    public var primaryKeyValue: ModelId {
        
        get {
            //get the name of the property first
            let propertyName = self.entity.primaryKeyName
            if  self.attributes[propertyName] != nil,
                let modelId = self.value(forKey: propertyName) as? ModelId  {
                return modelId
            }
            return 0
        }
        
        set {
            //get the name of the property first
            let propertyName:String = self.entity.primaryKeyName
            if self.attributes[propertyName] != nil {
                self.setValue(newValue, forKey:propertyName)
            }
        }
    }
    
    
    /// Dictionary of the properties changed for this model keyed by their Json key. This is ready to be sent over to the
    /// server for the object to be updated
    public var changedProperties:[String:String] {
        
        var changed:[String:String] = [:]
        
        for (name,value) in self.changedValues() {
            if let attribute:NSAttributeDescription = self.attributes[name]  {
                changed[attribute.jsonKey] = String(describing: value)
            }
        }
        
        return changed
        
    }
    
    /// Dictionary of the relations to be changed changed for this model keyed by their Json key. This is ready to be sent over to the
    /// server for the object to be updated
    public var changedOneRelation:[String:Dictionary<String,Array<ModelId>>] {
        
        var changed:[String:Dictionary<String,Array<ModelId>>] = [:]
        
        for (name,value) in self.changedValues() {
            if let attribute:NSRelationshipDescription = self.oneRelations[name],
                let jsonKey:String = attribute.jsonKey,
                let model:ConnectModel = value as? ConnectModel  {
                
                if  changed[jsonKey] == nil  {
                    changed[jsonKey] = Dictionary<String,Array<ModelId>>()
                    changed[jsonKey]! ["add"] = Array<ModelId>()
                    changed[jsonKey]! ["remove"] = Array<ModelId>()
                }
                changed[jsonKey]!["add"]!.append(model.primaryKeyValue )
            }
        }
        
        return changed
        
    }
    
    
    /// when creating a model object from json it can happen that instead of having the full dictionary with all values
    /// only the value for the primary key is available. hasData is true if data was pulled from API for this instance.
    public var hasData: Bool {
        get {
            if let hasIt:Bool = self.value(forKey: "hasData") as? Bool  {
                return hasIt
            }
            return false
        }
    }
    

    /// the name of the property that is the primary key for this object
    public var primaryKeyName: String {
        
        get {
            return self.entity.primaryKeyName
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
    
    public private(set) var connectRelations:Dictionary<String, ConnectRelationProtocol>!
    
    static func findWithId(in context: NSManagedObjectContext, id:ModelId) -> Self? {
        let predicate = NSPredicate(format: self.entity().primaryKeyName + " == %i",id)
        return self.findOrFetch(in: context, matching: predicate )
    }
    
    
    public func setupRelation<M:ConnectModel,T:ConnectRelation<M>>(name:String) -> T! {
        
        if(self.connectRelations == nil){
            self.connectRelations = Dictionary()
        }
        
        let relations:[String : NSRelationshipDescription] = self.entity.relationshipsByName
        let relation = T(parent: self, description:relations[name]!)
        self.connectRelations[name] = relation
        return relation
        
    }
    
    
    
    
    
    /// fetch an attribute value from the object and returns it as string if possible.
    /// if the value can't be casted to a String it will return the default value
    /// - Parameters:
    ///   - name: String, name of the attribute
    ///   - defaultValue: a default value that will be returned in case the attribute doesn't exists or is not a String
    /// - Returns: String value of the attribute or default
    public func stringAttribute(name:String, defaultValue:String = "null") -> String {
        if let valueP = self.attributes[name] {
            if let value:String = self.value(forKey: valueP.name) as? String {
                return value
            }
        }
        return defaultValue
    }
    

    public func numberAttribute(name:String, defaultValue:NSNumber = 0.0) -> NSNumber {
        if let valueP = self.attributes[name] {
            if let value:NSNumber = self.value(forKey: valueP.name) as? NSNumber {
                return value
            }
        }
        return defaultValue
    }
    
    public func reloadFromContext() {
        if let c = self.managedObjectContext {
            c.performAndWait {
                c.refresh(self, mergeChanges: false)
            }
        }
    }
    
    /// Save operation for this model instance. Save operation are not as simple as saving to Core Data
    /// The framework will first try to post the changes back to the API and then eventually sync back the object if the operation
    /// succeeds.
    ///
    /// - Parameter done: the block to invoke when the save operation is completed
    /// - Returns: a LaravelTask in charge of the Save operation.
    public func save(done:@escaping (NSManagedObjectID?, Error?) -> Void) -> LaravelTask? {

        return  LaravelConnect.shared().save(model: self, done: done)

    }
    
    
    public func refresh(include:[String] = [], done:@escaping (NSManagedObjectID?, Error?) -> Void) -> LaravelTask {
        return LaravelConnect.shared().get(model:type(of: self),
                                           modelId: self.primaryKeyValue,
                                           include:include, done:{ (managedId, error) in
                                                                            //refresh the object before calling the done block
                                                                            self.reloadFromContext()
                                                                            done(managedId, error)
            })
    }
    
    override open var description : String {
        
        if let title:String = ConnectModel.connect().presenterForClass(className: "\(type(of: self))" ).modelTitle(model: self) {
            return title
        }
        
        return "\(type(of: self)) \(self.primaryKeyValue)"
    }
    
    override open var debugDescription : String {
        return "\(type(of: self)) \(self.primaryKeyValue)"
    }
    
    
    
    public static func connect() -> LaravelConnect {
        return LaravelConnect.shared()
    }
    
    
    public static func get(modelId: ModelId, include:[String] = [], done:@escaping (NSManagedObjectID?, Error?) -> Void) -> LaravelTask {
        return LaravelConnect.shared().get(model:self, modelId: modelId, include:include, done: done)
    }
    
    public static func list(filter: Filter = Filter(), include:[String] = []) -> ModelList {
        return LaravelConnect.shared().list(model:self, relation:nil, filter:filter, include:include)
    }
}
