//
//  Sort.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 10/02/2018.
//

import Foundation

public class Sort {
    
    public let paramName:String
    private var options:Set<SortOption>
    
    public var firstOption:SortOption? {
        get {
            return options.first
        }
    }
    
    public init(paramName:String = "sort_by"){
        self.paramName = paramName
        self.options = Set()
    }
    
    public func add(field:String, order:SortOption.Order) {
        self.options.insert(SortOption(field: field, order: order))
    }
    
    public func serialize() -> Dictionary<String,String> {
        
        var params = Dictionary<String,String>()
        
        for option:SortOption in self.options {
            let name = "\(self.paramName)[\(option.field)]"
            params[name] = option.order.rawValue
        }
        
        return params
    }
}
