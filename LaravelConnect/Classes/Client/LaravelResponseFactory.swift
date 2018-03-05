//
//  LaravelPaginatedModelResponse.swift
//  LaravelConnect
//
//  Created by Roberto Prato on 31/01/2018.
//

import Foundation

import Foundation
import Square1CoreData
import Square1Network
import CoreData


// approach taken from
// https://stackoverflow.com/questions/46595917/swift-4-json-decoding-when-type-is-only-known-at-runtime
private struct DecodingHelper: Decodable {
    
    private let decoder: Decoder
    
    public init(from decoder: Decoder) throws {
        self.decoder = decoder
    }
    
    func decode<T : Decodable>(to type: T.Type) throws -> T {
        let decodable = try type.init(from: decoder)
        return decodable
    }
}

public protocol LaravelResponseFactory {
    func responseForData(_ data: Data) throws -> LaravelResponse
}

/**
 This simply parses a json into a response
 */
public class LaravelDefaultResponseFactory : LaravelResponseFactory {

    let responseType : LaravelResponse.Type
    
    public init(responseType : LaravelResponse.Type = LaravelResponse.self){
        self.responseType = responseType
    }
    
    public func responseForData(_ data: Data) throws -> LaravelResponse {
        return self.responseType.init(with: data.toJSON())
    }
}

//get a paginated list of objects and store them in CoreData only if they are not there yet.
public class LaravelCoreDataMoldelListResponseFactory : LaravelDefaultResponseFactory {
    
    
    public override func responseForData(_ data: Data) throws -> LaravelResponse {
        let reponse = try super.responseForData(data)
        try reponse.storeModelObjects(coreData: self.coreData, model: self.model)
        return reponse
    }
//
    
    private let coreData: CoreDataManager
    private let model: ConnectModel.Type
    
    init(coreData: CoreDataManager, model: ConnectModel.Type){
        self.coreData = coreData
        self.model = model
        super.init(responseType: LaravelPaginatedModelResponse.self)
    }
    
    init(coreData: CoreDataManager, showModel: ConnectModel.Type){
        self.coreData = coreData
        self.model = showModel
        super.init(responseType: LaravelSingleObjectModelResponse.self)
    }

}

