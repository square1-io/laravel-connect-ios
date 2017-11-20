//
//  LaravelConnectClient.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 19/11/2017.
//

import UIKit


class LaravelConnectClient: NSObject {

    var settings : LaravelSettings
    
    public init(settings : LaravelSettings){
        self.settings = settings
    }
    
    public func execute(request : LaravelRequest){
        
    }
    
    private func get(){}
    
    private func post(){}
    
    private func delete(){}
    
}
