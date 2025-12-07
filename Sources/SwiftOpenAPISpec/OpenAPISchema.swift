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
    public static let PROPERTIES_KEY = "properties"
    public static let UNEVALUATEDPROPERTIES_KEY = "unevaluatedProperties"
    public static let REQUIRED_KEY = "required"
   
    public init(_ map: [AnyHashable : Any]) throws {
        if let type = map[Self.TYPE_KEY] as? String,
            let validatableType = OpenAPIDefaultSchemaType.validatableType(type) {
            self.type = try validatableType.init(map)
        }
        self.format = DataType(rawValue:map[Self.FORMAT_KEY] as? String ?? DataType.string.rawValue)
        
        if let propertiesMap = map[Self.PROPERTIES_KEY] as? [AnyHashable:Any]{
            self.properties = try MapListMap.map(propertiesMap )
        }
        self.required = map[Self.REQUIRED_KEY] as? [String] ?? []
    }
    
    public var type : OpenAPIValidatableSchemaType?
    //https://datatracker.ietf.org/doc/html/draft-bhutton-json-schema-validation-01  ("null", "boolean", "object", "array", "number", or "string"), or "integer"
    public var format : DataType? = nil
    public var properties : [OpenAPISchemaProperty] = []
    public var unevaluatedProperties : Bool = false
    public var required : [String] = []
    
}
