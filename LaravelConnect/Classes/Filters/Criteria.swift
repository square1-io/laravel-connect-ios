//
//  Criteria.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 19/12/2017.
//

import Foundation


let CONTAINS = "contains";
let EQUAL = "equal";
let NOTEQUAL = "notequal";
let GREATERTHAN = "greaterthan";
let LOWERTHAN = "lowerthan";
let GREATERTHANOREQUAL = "greaterthanorequal";
let LOWERTHANOREQUAL = "lowerthanorequal";

public class Criteria : NSObject {
    
    public let param: String
    let relation: String?
    let verb: String
    let value: String
    
    init(param:String, verb:String, value:String, relation:String) {
        self.param = param
        self.verb = verb
        self.value = value
        self.relation = relation
        
        super.init();
    }
    
    convenience init(param:String, verb:String, value:String) {
        self.init(param: param, verb: verb, value:value, relation: "")
    }
    
    public var key: String {
        
        get {
            if(relation != nil) {
                return relation! + "." + param
            }
            return param
        }
    }
    
}
