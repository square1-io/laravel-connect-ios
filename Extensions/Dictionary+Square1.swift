//
//  Data+Square1.swift
//  Square1Network
//
//  Created by Roberto Prato on 08/03/2018.
//  Copyright © 2018 Square1. All rights reserved.
//

import UIKit

extension Dictionary where Key == String {

   
    public func stringValueForKey(key:String, defaultValue:String?) -> String? {
        return self.valueForKey(key: key, defaultValue: defaultValue)
    }
 
    public func arrayValueForKey<T>(key:String) -> [T]? {
       
        if let value:[T] = self[key] as? [T]  {
            return value
        }
        
        return nil
    }
    
    public func dictionaryValueForKey<K,V>(key:String) -> [K:V]? {
        return self.valueForKey(key: key, defaultValue: nil)
    }


    
   public func valueForKey<T>(key:String, defaultValue:T?) -> T? {
    
        if let value:T = self[key] as? T  {
                return value
        }
        
        return defaultValue
    }
    
    
    
}
