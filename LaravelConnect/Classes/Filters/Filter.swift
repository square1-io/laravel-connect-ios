//
//  FilterCollection.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 19/12/2017.
//

import Foundation

public class Filter : NSObject {
    
    var filters : Array<CriteriaCollection> = []
    
    public override init() {
        super.init()
        self.filters.append(CriteriaCollection())
    }
    
    private var current: CriteriaCollection! {
        get {
            return self.filters.last
        }
    }
    
    public func or() -> Filter {
        self.filters.append(CriteriaCollection())
        return self
    }
    
    public func contains(param: String, value: String)  -> Filter {
        self.current.contains(param: param, value: value)
        return self
    }
    
    public func equal(param: String, value: String)  -> Filter {
        self.current.equal(param: param, value: value)
        return self
    }
    
    public func notEqual(param: String, value: String) -> Filter{
        self.current.notEqual(param: param, value: value)
        return self
    }
    
    public func greatherThan(param: String, value: String) -> Filter{
        self.current.greatherThan(param: param, value: value)
        return self
    }
    
    public func lowerThan(param: String, value: String) -> Filter{
        self.current.lowerThan(param: param, value: value)
        return self
    }
    
    public func lowerThanOrEqual(param: String, value: String) -> Filter{
        self.current.lowerThanOrEqual(param: param, value: value)
        return self
    }
    
    public func greatherThanOrEqual(param: String, value: String) -> Filter{
        self.current.greatherThanOrEqual(param: param, value: value)
        return self
    }
    
    public func serialise(param: String) -> Array<String> {
        
        var collections = Array<String>()
        
        var index : Int = 0
        
        for filter in self.filters {
            
            let serialisedFilters = filter.serialise()
            
            for ser in serialisedFilters {
                let currentFilter = "\(param)[\(index)]" + ser
                collections.append(currentFilter)
            }
            
            index = index + 1
        }
        
        return collections
    }
    
}
