//
//  ModelList.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 03/12/2017.
//

import Foundation


public class ModelList : NSObject {
    
    private let request: LaravelRequest
    private var lastTask: LaravelTask?
    private var currentPage: Pagination
    
    init(request: LaravelRequest)  {
        self.request = request
        self.currentPage = Pagination.NOPAGE
      
        super.init()
    }
    
    public func nextPage() -> Bool {
        
        if(self.currentPage.hasNext){
            request.setPage(page: self.currentPage.nextPage)
            self.lastTask = LaravelConnect.sharedInstance.execute(request: request)
            return true
        }
        
        return false
        
    }
}
