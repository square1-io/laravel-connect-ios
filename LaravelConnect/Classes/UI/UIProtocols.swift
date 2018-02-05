//
//  UIProtocols.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 04/02/2018.
//

import Foundation

public typealias ModelInstanceTitle = (_ :ConnectModel?) -> String
public typealias ModelInstanceSubTitle = (_ :ConnectModel?) -> String

public struct ModelInfo {
    let modelType:ConnectModel.Type
    let modelTitle: ModelInstanceTitle
    let modelSubtitle: ModelInstanceSubTitle
    
    public init(modelType:ConnectModel.Type,
                modelTitle: @escaping ModelInstanceTitle,
                modelSubtitle: @escaping ModelInstanceSubTitle) {
        self.modelType = modelType
        self.modelTitle = modelTitle
        self.modelSubtitle = modelSubtitle
    }
    
}
