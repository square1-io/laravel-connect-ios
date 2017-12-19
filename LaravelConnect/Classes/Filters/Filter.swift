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

public class Filter : NSObject {
    
    var criterias : Dictionary<String,  Dictionary<String, Array<Criteria>>>
    
    public override init() {
        self.criterias = Dictionary()
    }
    
    public func addCriteria(criteria: Criteria){
        
        var list = self.criterias[criteria.key]
        
        if(list == nil){
            list = Dictionary();
            self.criterias[criteria.key] = list;
        }
        
        var verbs = list![criteria.verb]
        
        if(verbs == nil){
            verbs = Array();
            list![criteria.verb] = verbs
        }

        verbs?.append(criteria)
    }
    
    public func serialise() -> Array<String> {
        
        var serialised = Array<String>()
        
        for (key, criterias) in self.criterias {
            
            let criteriasList = self.serializeCriteriaCollection(criterias: criterias)
            
            for index in (0 ..< criteriasList.count) {
                let value : String = criteriasList[index]
                serialised.append(key + "[\(index)]" + value)
            }
        }
        
        return serialised
    }
    
    private func serializeCriteriaCollection(criterias: Dictionary<String, Array<Criteria>>) -> Array<String>{
        
        var serialised = Array<String>()
        
        for (key, list) in criterias {
            
            //let criteriasList = self.serializeCriteriaCollection(criterias: criterias)
            
            for  index in (0 ..< list.count){
                serialised.append(key+"[\(index)]"+list[index].value)
            }
        }
        
        return serialised
        
    }
    
}
