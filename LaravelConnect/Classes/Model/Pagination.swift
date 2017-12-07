//
//  Pagination.swift
//  FBSnapshotTestCase
//
//  Created by Roberto Prato on 03/12/2017.
//

import Foundation


public struct Pagination : Codable {
    
    static let NOPAGE = Pagination(currentPage: 0, total: 0, perPage: 15)
    
    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case total = "total"
        case perPage = "per_page"
    }
    
    public var currentPage: Int
    public var total: Int = -1
    public var perPage: Int
    
    public var nextPage: Int {
        get {
            return self.currentPage + 1
        }
    }
    
    public var pageCount: Int {
        get {
            let count = self.total / self.perPage
            let mod = self.total % self.perPage
            return count + ((mod > 0) ? 1 : 0)
        }
    }
    
    public var hasNext : Bool {
        get {// if total < 0 , means we have never requested the first page so we don't know how many pages are there
            return self.total < 0 || self.currentPage < self.total
        }
    }
    
}
