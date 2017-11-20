//
//  ConnectSettings.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 19/11/2017.
//

import UIKit

public protocol LaravelSettings {
    
    var baseApiUrl: String { get }
    
}

public class BaseConnectSettings : NSObject , LaravelSettings {
    
    public var baseApiUrl: String = ""
}
