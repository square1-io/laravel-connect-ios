//
//  SampleAppConnectSettings.swift
//  LaravelConnect_Example
//
//  Created by Roberto Prato on 03/12/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import LaravelConnect

public class LocalConnectSettings: AppSettings {
    
    public let apiHost: String = "connect-demo.mobile1.local"
    
    public let cacheDisabled: Bool = true
    public let httpScheme: String = "http"
    public let apiIncludeOneRelations: Bool = true
 
}
