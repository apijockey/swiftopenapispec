//
//  File 2.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation
//superset of https://datatracker.ietf.org/doc/html/draft-bhutton-json-schema-00
//https://spec.commonmark.org
//https://spec.openapis.org/oas/3.1/dialect/base
//https://json-schema.org
//https://datatracker.ietf.org/doc/html/draft-bhutton-json-schema-validation-00
// dialect:
//https://spec.openapis.org/oas/3.1/dialect/base
//
//https://swagger.io/docs/specification/data-models/oneof-anyof-allof-not/




public struct OpenAPISchema :  ThrowingHashMapInitiable {
    public enum DataType : String, CaseIterable {
        case integer, int32, int64, number, string
    }
    public static let TYPE_KEY = "type"
    public static let FORMAT_KEY = "format"
    
   
    public init(_ map: [AnyHashable : Any]) throws {
        if let type = map[Self.TYPE_KEY] as? String,
            let validatableType = OpenAPIDefaultSchemaType.validatableType(type) {
            self.type = try validatableType.init(map)
        }
        self.format = DataType(rawValue:map[Self.FORMAT_KEY] as? String ?? DataType.string.rawValue)
        
       
    }
    
    public var type : OpenAPIValidatableSchemaType?
    //https://datatracker.ietf.org/doc/html/draft-bhutton-json-schema-validation-01  ("null", "boolean", "object", "array", "number", or "string"), or "integer"
    public var format : DataType? = nil
   
    
}
