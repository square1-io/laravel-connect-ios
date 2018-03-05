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
//  Created by Roberto Prato on 03/12/2017.
//

import Foundation
import CoreData

public struct ModelListIterator: IteratorProtocol {
    
    private var ids:[Int64]
    public private(set) var items:Dictionary<Int64, ConnectModel>

    var currentIndex = 0
    
    init(ids:[Int64],items:Dictionary<Int64, ConnectModel>) {
       self.items = items
       self.ids = ids
    }
    
    mutating public func next() -> ConnectModel? {
        let nextIndex = currentIndex + 1
        guard nextIndex < self.ids.count
            else { return nil }
        
        currentIndex = nextIndex
        let currentId = self.ids[currentIndex]
        return self.items[currentId]
    }
}

public class ModelList : NSObject, Sequence {
    
    private var request: LaravelRequest!
    private let filter: Filter
    public let sort: Sort
    private var ids:[ModelId]
    private var items:Dictionary<ModelId, ConnectModel>
    public let entity:NSEntityDescription
    public var entityName:String {
        get {
            if let n = self.entity.name {
                return n
            }
            return ""
        }
    }
    
    public var count: Int {
        get  {
            return self.ids.count
        }
    }
    
    public private(set) var currentPage: Pagination
    
    init(entity:NSEntityDescription, request:LaravelRequest, filter:Filter, sort:Sort = Sort())  {
        self.entity = entity
        self.request = request
        self.filter = filter
        self.sort = sort
        self.ids = []
        self.items = Dictionary()
        self.currentPage = Pagination.NOPAGE
        super.init()
        
        self.request.filter(filter: filter)
            .sort(sort: sort)
    }
    
    public func clone(newFilter:Filter? = nil, newSort:Sort? = nil) -> ModelList {
        
        var s:Sort = self.sort
        if  newSort != nil {
            s = newSort!
        }
        
        var f:Filter = self.filter
        if  newFilter != nil {
            f = newFilter!
        }

        return ModelList(entity:self.entity,
                         request:self.request,
                         filter:f, sort:s)
    }
    
    public func refresh(done:@escaping ([ModelId]?, Error?) -> Void) {
        self.ids.removeAll()
        self.currentPage = Pagination.NOPAGE
        self.nextPage(done: done)
    }
    
    public func cancel() {
        if(request.state == .Running){
            request.cancel()
        }
    }
    
    @discardableResult public func nextPage(done:@escaping ([ModelId]?, Error?) -> Void) -> Bool {
        
        if(self.currentPage.hasNext && request.state != .Running){
            
            //create a new request
            request = LaravelRequest(request: request)
            request.setPage(page: self.currentPage.nextPage)
            
            request.start(success: { (result) in
                let response = result as! LaravelPaginatedModelResponse
                self.handleSuccess(response:response)
                done(response.ids, nil)
            }, failure: { (error) in
                self.handleFailure(error: error)
                done(nil, error)
            })
            return true
        }
        
        return false
        
    }
    
    private func handleSuccess(response:LaravelPaginatedModelResponse) {
        self.currentPage = response.page()!
        self.ids.append(contentsOf:response.ids)
        let array = self.reloadItems()
        self.items = array.toDictionary(with: { $0.value(forKey: "id") as! Int64 })
        
    }
    
    private func handleFailure(error:Error) {
        
    }
    
    subscript(index: Int) -> ConnectModel? {
        
        guard index < self.ids.count else { return nil}
        let currentId:ModelId = self.ids[index]
        return self.items[currentId]
    }
    
    public func makeIterator() -> ModelListIterator {
        return ModelListIterator(ids: self.ids, items: self.items)
    }
    
    private func reloadItems(context:NSManagedObjectContext = LaravelConnect.shared().coreData().viewContext) -> [ConnectModel] {
       
        do{
            return try context.fetch(ids:self.ids, entityName:self.entity.name!) as! [ConnectModel]
        }
        catch let error as NSError {
#if DEBUG
    print(error)
#endif
        }
        
        return []
    }
    
}
