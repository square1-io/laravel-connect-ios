//
//  SortOption.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 10/02/2018.
//

import Foundation

public struct SortOption: Hashable {
    
    public static func == (lhs: SortOption, rhs: SortOption) -> Bool {
        return lhs == rhs
    }
    
    
    public enum Order:String {
        case ASC = "ASC"
        case DESC = "DESC"
    }
    
    public var field:String
    public var order:Order
    
    public var hashValue: Int {
        get {
            return field.hashValue
        }
        
    }
}
