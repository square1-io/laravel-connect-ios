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

public class Filter : NSObject {
    
    public let paramName:String
    
    var filters : Array<CriteriaCollection> = []
    
    public init(paramName:String = "filter") {
        self.paramName = paramName
        self.filters.append(CriteriaCollection())
        super.init()
    }
    
    private var current: CriteriaCollection! {
        get {
            return self.filters.last
        }
    }
    
    public func or() -> Filter {
        if(self.current.count > 0){
            self.filters.append(CriteriaCollection())
        }
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
    
    public func serialize() -> Dictionary<String,String> {
        
        var collections = Dictionary<String,String>()
        
        var index : Int = 0
        
        for filter in self.filters {
            
            let serialisedFilters = filter.serialise()
            
            for (k,v) in serialisedFilters {
                let currentFilter = "\(self.paramName)[\(index)]\(k)"
                collections[currentFilter] = v
            }
            
            index = index + 1
        }
        
        return collections
    }
    
}
