//
//  CoreDataManager.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 03/12/2017.
//

import Foundation
import CoreData

public class CoreDataManager : NSObject {
    
    private var storeName: String?
    
    private var modelName = ""
    
    private var modelBundle = Bundle.main
    
    private var persistentStoreCoordinator: NSPersistentStoreCoordinator?
    
    /**
     Initializes a CoreDataManager using the provided model name.
     - parameter modelName: The name of your Core Data model (xcdatamodeld).
     */
    @objc public init(modelName: String) {
        self.modelName = modelName
        
        super.init()
         ValueTransformer.setValueTransformer(UploadedImageCoreDataTransformer(), forName: .UploadedImageCoreDataTransformerName)
    }
    
    public func initCoreDataStack(completionClosure: @escaping () -> ()) {
        
        //This resource is the same name as your xcdatamodeld contained in your project
        guard let modelURL = Bundle.main.url(forResource: self.modelName, withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        self.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: mom)
        
    
        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        queue.async {
            guard let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
                fatalError("Unable to resolve document directory")
            }
            let storePath : String = self.modelName + ".sqlite";
            let storeURL = docURL.appendingPathComponent( storePath )
            do {
     
                var options = Dictionary<AnyHashable,Any>()
                    options[NSMigratePersistentStoresAutomaticallyOption] = true
                    options[NSInferMappingModelAutomaticallyOption] = true
                try self.persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
                //The callback block is expected to complete the User Interface and therefore should be presented back on the main queue so that the user interface does not need to be concerned with which queue this call is coming from.
                DispatchQueue.main.sync(execute: {
                     
                     completionClosure()
                })
            } catch {
                fatalError("Error migrating store: \(error)")
            }
        }
    }
    
    /**
     The context for the main queue. Please do not use this to mutate data, use `performInNewBackgroundContext`
     instead.
     */
    @objc public lazy var viewContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.undoManager = nil
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        return context
    }()
    
    @objc public func newBackgroundContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        context.undoManager = nil
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        
        //NotificationCenter.default.addObserver(self, selector: #selector(DataStack.backgroundContextDidSave(_:)), name: .NSManagedObjectContextDidSave, object: context)
        
        return context
    }

    public func entityDescriptionForClass(model: NSManagedObject.Type, context: NSManagedObjectContext) -> NSEntityDescription? {
        return model.entity()
        //return self.entityDescription(entityName: NSStringFromClass(model) , context: context)
    }
    
    public func entityDescription(entityName: String, context: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: entityName, in: context)
    }
    
    public func pathForModel(model: NSManagedObject.Type) -> String {

            return model.entity().modelPath

    }
    
}
