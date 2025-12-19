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




public struct OpenAPISchema :  KeyedElement, PointerNavigable {
    public var key: String?
    
   
    public static let TYPE_KEY = "type"
    public static let ALLOF_KEY = "allOf"
    public static let DISCRIMINATOR_KEY = "discriminator"
    public static let ONEOF_KEY = "oneOf"
    public static let ANYOF_KEY = "anyOf"
    public static let XML_KEY = "xml"
    public static let FORMAT_KEY = "format"
    
   
    public init(_ map: [String : Any]) throws {
        
        if let type = map[Self.TYPE_KEY] as? String,
            let validatableType = OpenAPISchemaType.validatableType(type) {
            self.schemaType = try validatableType.init(map)
        }
        else if map[Self.ANYOF_KEY] is [Any] {
            self.schemaType = try OpenAPIAnyOfType(map)
        }
        else if map[Self.ALLOF_KEY] is [Any] {
            self.schemaType = try OpenAPIAllOfType(map)
        }
        if let discriminatorMap = map[Self.DISCRIMINATOR_KEY] as? StringDictionary {
            self.discriminator = try OpenAPIDiscriminator(discriminatorMap)
        }
        
        
        else if map[Self.ONEOF_KEY] is [Any] {
            self.schemaType = try OpenAPIOneOfType(map)
        }
        if let refMap = map[OpenAPISchemaReference.REF_KEY] as? StringDictionary {
                   self.ref = try OpenAPISchemaReference(refMap)
               }
        if let ref = map[OpenAPISchemaReference.REF_KEY] as? String {
            self.ref = OpenAPISchemaReference(ref: ref)
               }
        if let xmlMap = map[Self.XML_KEY] as? StringDictionary {
            xml = try? OpenAPIXMLObject(xmlMap)
        }
        
        extensions = try OpenAPIExtension.extensionElements(map)
       
    }
    
    public var schemaType : OpenAPIValidatableSchemaType?
    //https://datatracker.ietf.org/doc/html/draft-bhutton-json-schema-validation-01  ("null", "boolean", "object", "array", "number", or "string"), or "integer"
    public var extensions : [OpenAPIExtension]?
    public var discriminator : OpenAPIDiscriminator?
   
    public var ref : OpenAPISchemaReference? = nil
    public var xml : OpenAPIXMLObject? = nil
    public var userInfos =  [OpenAPISpecification.UserInfo]()
    
   
    public func element(for segmentName : String) throws -> Any? {
        switch segmentName {
            
       
        case Self.TYPE_KEY : return self.schemaType
            case Self.ONEOF_KEY: return schemaType
            case Self.ALLOF_KEY : return schemaType
        
            case OpenAPISchemaReference.REF_KEY: return ref
        default:
            if let object = schemaType as? OpenAPISpecificationType{
                    return try object.element(for: segmentName)
                
            }
            else if let integer = schemaType as? OpenAPIIntegerType{
                return try integer.element(for: segmentName)
            }
            else if let oneOf = schemaType as? OpenAPIOneOfType{
                return try oneOf.element(for: segmentName)
            }
            else if let anyOf = schemaType as? OpenAPIAnyOfType{
                return try anyOf.element(for: segmentName)
            }
            else if let allOf = schemaType as? OpenAPIAllOfType{
                return try allOf.element(for: segmentName)
            }
            else if let string  = schemaType as? OpenAPIStringType{
                return try string.element(for: segmentName)
            }
            else if let double  = schemaType as? OpenAPIDoubleType{
                return try double.element(for: segmentName)
            }
            else if let array  = schemaType as? OpenAPIArrayType{
                return try array.element(for: segmentName)
            }
            //must lead to resolution of ref in the next traversal
            else if let ref = self.ref{
                return ref
            }
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPISchema", segmentName)
        }
    }
}
