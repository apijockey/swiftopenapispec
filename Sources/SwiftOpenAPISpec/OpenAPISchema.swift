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




public struct OpenAPISchema :  KeyedElement{
    public var key: String?
    
    public enum DataType : String, CaseIterable {
        case integer, int32, int64, number, string
    }
    public static let REF_KEY = "$ref"
    public static let TYPE_KEY = "type"
    public static let ALLOF_KEY = "allOf"
    public static let DISCRIMINATOR_KEY = "discriminator"
    public static let ONEOF_KEY = "oneOf"
    public static let ANYOF_KEY = "anyOf"
    public static let JSONREF_KEY = "$ref"
    public static let FORMAT_KEY = "format"
    
   
    public init(_ map: [String : Any]) throws {
        if let type = map[Self.TYPE_KEY] as? String,
            let validatableType = OpenAPISchemaType.validatableType(type) {
            self.schemaType = try validatableType.init(map)
        }
        else if map[Self.JSONREF_KEY] is String {
            self.schemaType = try OpenAPIValidatableType(map)
            
        }
        else if map[Self.ONEOF_KEY] is [Any] {
            self.schemaType = try OpenAPIOneOfType(map)
        }
        else if map[Self.ANYOF_KEY] is [Any] {
            self.schemaType = try OpenAPIAnyOfType(map)
        }
        else if map[Self.ALLOF_KEY] is [Any] {
            self.schemaType = try OpenAPIAllOfType(map)
        }
        self.ref = map.readIfPresent(Self.REF_KEY, String.self)
    
        extensions = try OpenAPIExtension.extensionElements(map)
       
    }
    
    public var schemaType : OpenAPIValidatableSchemaType?
    //https://datatracker.ietf.org/doc/html/draft-bhutton-json-schema-validation-01  ("null", "boolean", "object", "array", "number", or "string"), or "integer"
    public var format : DataType? = nil
    public var userInfos =  [OpenAPIObject.UserInfo]()
    public var extensions : [OpenAPIExtension]?
    public var ref: String? = nil
   
    public func element(for segmentName : String) throws -> Any? {
        switch segmentName {
            case Self.JSONREF_KEY : return self.schemaType
            case Self.TYPE_KEY : return self.schemaType
            case Self.ONEOF_KEY: return schemaType
            case Self.ALLOF_KEY : return schemaType
            case Self.REF_KEY : return self.ref
            
            default : throw OpenAPIObject.Errors.unsupportedSegment("OpenAPISchema", segmentName)
        }
    }
}
