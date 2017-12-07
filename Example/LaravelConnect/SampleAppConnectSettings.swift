//
//  SampleAppConnectSettings.swift
//  LaravelConnect_Example
//
//  Created by Roberto Prato on 03/12/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import LaravelConnect

public class SampleAppConnectSettings : NSObject, LaravelSettings {
    
    public let apiHost: String = ""
    public let cacheDisabled: Bool = true
    public let coreDataModelName = "sample"
    public let httpScheme: String = "http"
    public let apiRootPathSegments: [String] = []

 
}
