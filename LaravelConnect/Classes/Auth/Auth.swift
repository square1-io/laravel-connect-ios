//
//  Auth.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 19/11/2017.
//

import UIKit

class Auth: NSObject {
    
    private static var sInstance : Auth!

    var laravelConnect : LaravelConnect
    
    private init(laravelConnect : LaravelConnect) {
        self.laravelConnect = laravelConnect
    }
    
    
    public class func setup(laravelConnect : LaravelConnect){
        sInstance = Auth(laravelConnect:laravelConnect)
    }

}
