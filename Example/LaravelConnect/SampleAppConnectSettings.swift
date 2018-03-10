//
//  SampleAppConnectSettings.swift
//  LaravelConnect_Example
//
//  Created by Roberto Prato on 03/12/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import LaravelConnect

public class SampleAppConnectSettings: LaravelSettings {

    public let apiHost: String = "connect-demo.mobile1.local" // "connect-demo.mobile1.io"
    public let cacheDisabled: Bool = true
    public let coreDataModelName = "laravel_connect"
    public let httpScheme: String = "http"
    public let apiRootPathSegments: [String] = ["square1", "connect"]

    public let apiKeyHeaderName = "x-connect-api-key"
    public let apiKeyValue = ""
    
    public let apiIncludeOneRelations: Bool = true
 
}
