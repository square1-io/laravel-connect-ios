//
//  Data+Square1.swift
//  Square1Network
//
//  Created by Roberto Prato on 08/03/2018.
//  Copyright © 2018 Square1. All rights reserved.
//

import UIKit

extension Data {

    func toJson() -> [String: AnyObject]? {
    
            do {
                return try JSONSerialization.jsonObject(with: self, options: []) as? [String: AnyObject]
            } catch {
                print(error.localizedDescription)
            }
        
        return nil
    }
    
}

extension NSMutableData {
    func append(_ string: String) {
        let data = string.data(using: .utf8, allowLossyConversion: false)
        append(data!)
    }
}
