//
//  Auth.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 19/11/2017.
//

import UIKit

class Auth: NSObject {
    
    private static var sInstance : Auth!

    var laravel : LaravelConnectClient
    var settings : LaravelSettings
    
    private init(laravel : LaravelConnectClient, settings : LaravelSettings) {
        self.laravel = laravel
        self.settings = settings;
    }
    
    
    public class func setup(client : LaravelConnectClient, settings: LaravelSettings){
        sInstance = Auth(laravel:client, settings: settings)
    }

}
