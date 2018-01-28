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


let CONTAINS = "contains";
let EQUAL = "equal";
let NOTEQUAL = "notequal";
let GREATERTHAN = "greaterthan";
let LOWERTHAN = "lowerthan";
let GREATERTHANOREQUAL = "greaterthanorequal";
let LOWERTHANOREQUAL = "lowerthanorequal";

 class Criteria : NSObject {
    
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
        let components = param.components(separatedBy: ".")
        self.init(param: components.last!, verb: verb,
                  value:value,
                  relation: (components.count > 1 ? components[0] : ""))
    }
    
    public var key: String {
        
        get {
            if((relation?.isEmpty)! == false) {
                return relation! + "." + param
            }
            return param
        }
    }
    
}
