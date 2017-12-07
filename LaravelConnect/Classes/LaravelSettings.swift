//
//  ConnectSettings.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 19/11/2017.
//

import Foundation

public protocol LaravelSettings {
    
    var httpScheme: String { get }
    
    var apiHost: String { get }
    
    //array of the root path elements for the API ["api","v1"] => /api/v1/
    var apiRootPathSegments: [String] { get }
    
    var cacheDisabled : Bool {get }
    
    var coreDataModelName : String { get }
}


