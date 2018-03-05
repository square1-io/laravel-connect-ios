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

    public var count:Int {
        get {
            return self.criterias.count
        }
    }

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
    
    public func serialise() -> Dictionary<String,String> {
        
        var serialised = Dictionary<String,String>()
        
        for (key, criterias) in self.criterias {
            
            let criteriasList = self.serializeCriteriaCollection(criterias: criterias)
            
            for (k,v) in criteriasList {
                serialised["[\(key)]\(k)"] = v
                //serialised.append("[\(key)]\(value)" )
            }
        }
        
        return serialised
    }
    
    private func serializeCriteriaCollection(criterias: Dictionary<String, Array<Criteria>>) -> Dictionary<String,String>{
        
        var serialised = Dictionary<String,String>()
        
        for (key, list) in criterias {
            
            for  index in (0 ..< list.count){
                serialised["[\(key)][\(index)]"] = "\(list[index].value)"
            }
        }
        
        return serialised
        
    }
    
}
