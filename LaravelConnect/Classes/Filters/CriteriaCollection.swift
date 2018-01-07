//
//  Filter.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 19/12/2017.
//

import Foundation

/**
 "filter[0][medias.event_id][equal][0]": eventId,
 "filter[0][medias.event_id][equal][1]": 5,
 "filter[0][id][equal][1]": 52323,
 "filter[1][medias.event_id][equal][0]": 666,
 "filter[1][medias.event_id][equal][1]": 666,
 "filter[1][id][equal][1]": 52323
 **/

public class CriteriaCollection : NSObject {
    
    var criterias : [String: [String: [Criteria]]] = [String: [String: [Criteria]]]()


    public func contains(param: String, value: String){
        self.addCriteria(criteria: Criteria(param:param, verb:CONTAINS, value:value))
    }

    public func equal(param: String, value: String){
        self.addCriteria(criteria: Criteria(param:param, verb:EQUAL, value:value))
    }
    
    public func notEqual(param: String, value: String){
        self.addCriteria(criteria: Criteria(param:param, verb:NOTEQUAL, value:value))
    }
    
    public func greatherThan(param: String, value: String){
        self.addCriteria(criteria: Criteria(param:param, verb:GREATERTHAN, value:value))
    }
    
    public func lowerThan(param: String, value: String){
        self.addCriteria(criteria: Criteria(param:param, verb:LOWERTHAN, value:value))
    }
    
    public func lowerThanOrEqual(param: String, value: String){
        self.addCriteria(criteria: Criteria(param:param, verb:LOWERTHANOREQUAL, value:value))
    }
    
    public func greatherThanOrEqual(param: String, value: String){
        self.addCriteria(criteria: Criteria(param:param, verb:GREATERTHANOREQUAL, value:value))
    }
    
    private func addCriteria(criteria: Criteria){
        
     
        if(self.criterias[criteria.key] == nil){
            self.criterias[criteria.key] = [:]
        }

        if(self.criterias[criteria.key]![criteria.verb] == nil){
            self.criterias[criteria.key]![criteria.verb] = []
        }

        self.criterias[criteria.key]![criteria.verb]?.append(criteria)
    }
    
    public func serialise() -> Array<String> {
        
        var serialised = Array<String>()
        
        for (key, criterias) in self.criterias {
            
            let criteriasList = self.serializeCriteriaCollection(criterias: criterias)
            
            for index in (0 ..< criteriasList.count) {
                let value : String = criteriasList[index]
                serialised.append("[\(key)]\(value)" )
            }
        }
        
        return serialised
    }
    
    private func serializeCriteriaCollection(criterias: Dictionary<String, Array<Criteria>>) -> Array<String>{
        
        var serialised = Array<String>()
        
        for (key, list) in criterias {
            
            for  index in (0 ..< list.count){
                serialised.append("[\(key)][\(index)]="+list[index].value)
            }
        }
        
        return serialised
        
    }
    
}
