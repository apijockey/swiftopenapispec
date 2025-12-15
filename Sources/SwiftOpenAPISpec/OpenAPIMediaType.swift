//
//  File.swift
//
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation

public struct OpenAPIMediaType :  KeyedElement , PointerNavigable {
    public static let SCHEMA_KEY = "schema"
    public static let EXAMPLES_KEY = "examples"
    public var key : String?
    public init(_ map: [String : Any]) throws {
        if map[Self.SCHEMA_KEY] != nil {
            let schemaMap = try map.tryRead(Self.SCHEMA_KEY, StringDictionary.self, root: "OpenAPIMediaType")
            self.schema =  try OpenAPISchema(schemaMap)
            
            
            if let examplesMap  = map[Self.EXAMPLES_KEY]  as? StringDictionary{
                self.examples = try KeyedElementList.map(examplesMap)
            }
            
            
        }
    }
    
    public func element(for segmentName: String) throws -> Any? {
        switch segmentName {
        case Self.SCHEMA_KEY:
            return self.schema
        case Self.EXAMPLES_KEY:
            return self.examples
        default:
            throw OpenAPIObject.Errors.unsupportedSegment("OpenAPIMediaType", segmentName)
        }
    }
    public var schema : OpenAPISchema? = nil
    public var examples : [OpenAPIExample] = []
    public var userInfos =  [OpenAPIObject.UserInfo]()
    public var ref : String? // PointerNavigable
    //ENCODING
}

