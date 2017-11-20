//
//  LaravelConnect.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 19/11/2017.
//

import UIKit

public class LaravelConnect: NSObject {
    
    private static let sInstance = LaravelConnect();
    
  
    private var httpClient : LaravelConnectClient!
    
    private override init() {
        
    }
    
    public class func setup(settings : LaravelSettings = BaseConnectSettings()){
        
        // read settings
        let settings = BaseConnectSettings()
        
        // create API client that will make all REST requests
        sInstance.httpClient = LaravelConnectClient(settings: settings)
        
        // init Auth 
        Auth.setup(client: sInstance.httpClient, settings: settings)
    }

    internal class func client() -> LaravelConnectClient {
        return sInstance.httpClient
    }
}
