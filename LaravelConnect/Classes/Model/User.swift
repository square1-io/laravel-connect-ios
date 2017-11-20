//
//  User.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 19/11/2017.
//


import Foundation
import CoreData



@objc(JobQuotation)
public class User: NSManagedObject {
    
    class var modelPath: String {
        return "user"
    }
    
    class var primaryKey: String {
        return "id"
    }
    
}

extension User {
    
    @nonobjc  public class func fetchRequest() -> NSFetchRequest<User> {
        User.
        return NSFetchRequest<User>(entityName: "User")
    }
    
}
