/*
 * Copyright 2025 CgSe Computergrafik und Softwareentwicklung GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


//  Created by Patric Dubois on 26.03.24.
//

import Foundation

public struct OpenAPISchema :  KeyedElement, PointerNavigable, OpenAPISchemaReferenceable,Equatable {
    public static func == (lhs: OpenAPISchema, rhs: OpenAPISchema) -> Bool {
        return false
    }
    
   
    static let NULLABLE_KEY = "nullable"
    public static let TYPE_KEY = "type"
    
    public static let ONEOF_KEY = "oneOf"
    public static let ANYOF_KEY = "anyOf"
    public static let XML_KEY = "xml"
    public static let ALLOF_KEY = "allOf"
   
    public static let DISCRIMINATOR_KEY = "discriminator"
    
    public static let FORMAT_KEY = "format"
    
    public init() {
        
    }
    public func clone() -> OpenAPISchema {
        var newSchema = OpenAPISchema()
        newSchema.ref = self.ref
       
        newSchema.extensions = self.extensions
        newSchema.discriminator = self.discriminator
        newSchema.ref = self.ref
        newSchema.nullable = self.nullable
        newSchema.xml = self.xml
        return newSchema
    }
    public static func initialize(_ map: StringDictionary) throws ->  InitializationResult<Self> {
           let element = try Self(load: map)
           return InitializationResult(value: element, diagnostics: [])
       }

    public init(load map: [String : Any]) throws {
        if let ref  =  try OpenAPISchemaReference.initReference(from: (map)) {
            self.ref = ref
            return
        }
        
           
        
        
        if let discriminatorMap = map[Self.DISCRIMINATOR_KEY] as? StringDictionary {
            self.discriminator = try OpenAPIDiscriminator(load: discriminatorMap)
        }
        
        
        
        self.format30 = map.readIfPresent(Self.FORMAT_KEY, String.self)
        extensions = try OpenAPIExtension.extensionElements(map)
        self.nullable = map.readIfPresent(Self.NULLABLE_KEY, Bool.self) ?? false
    }
    
   
    //https://datatracker.ietf.org/doc/html/draft-bhutton-json-schema-validation-01  ("null", "boolean", "object", "array", "number", or "string"), or "integer"
    public var extensions : [OpenAPIExtension]?
    public var discriminator : OpenAPIDiscriminator?
    public var format30 : String? = nil
    public var key: String?
    public var arrayType: OpenAPIArrayType?
    public var objectType: OpenAPIObjectType?
    public var stringType: OpenAPIStringType?
    public var integerType: OpenAPIIntegerType?
    public var unknownType: OpenAPIUnknownType?
    public var numberType: OpenAPIDoubleType?
    public var booleanType: OpenAPIBooleanType?
    public var allOf: OpenAPIAllOfType?
    public var oneOf: OpenAPIOneOfType?
    public var anyOf: OpenAPIAnyOfType?
    public var ref : OpenAPISchemaReference?
    public var xml : OpenAPIXMLObject? = nil
    public var nullable : Bool = false // 3.0
    
    public var hasTypeInfo : Bool {
        return self.ref != nil || self.allOf != nil || self.oneOf != nil || self.anyOf != nil || self.booleanType != nil || self.integerType != nil || self.objectType != nil || self.stringType != nil || self.numberType != nil
    }
    public func element(for segmentName : String) throws -> Any? {
       // switch segmentName {
            
       
//        case Self.TYPE_KEY : return self.schemaType
//            case Self.ONEOF_KEY: return schemaType
//            case Self.ALLOF_KEY : return schemaType
//        
//            case OpenAPISchemaReference.REF_KEY: return ref
//        default:
//            if let object = schemaType as? OpenAPIObjectType{
//                    return try object.element(for: segmentName)
//                
//            }
//            else if let integer = schemaType as? OpenAPIIntegerType{
//                return try integer.element(for: segmentName)
//            }
//            else if let oneOf = schemaType as? OpenAPIOneOfType{
//                return try oneOf.element(for: segmentName)
//            }
//            else if let anyOf = schemaType as? OpenAPIAnyOfType{
//                return try anyOf.element(for: segmentName)
//            }
//            else if let allOf = schemaType as? OpenAPIAllOfType{
//                return try allOf.element(for: segmentName)
//            }
//            else if let string  = schemaType as? OpenAPIStringType{
//                return try string.element(for: segmentName)
//            }
//            else if let double  = schemaType as? OpenAPIDoubleType{
//                return try double.element(for: segmentName)
//            }
//            else if let array  = schemaType as? OpenAPIArrayType{
//                return try array.element(for: segmentName)
//            }
//            //must lead to resolution of ref in the next traversal
//            else if let ref = self.ref{
//                return ref
//            }
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPISchema", segmentName)
        }

}

/*
 self.type = map[Self.TYPE_KEY] as? String
 if let refMap = map["$ref"] as? StringDictionary {
     ref = try OpenAPISchemaReference(load:refMap)
 }
 if map[Self.ONEOF_KEY] is [Any] {
     oneOf = try OpenAPIOneOfType(load: map)
 }
 else if map[Self.ANYOF_KEY] is [Any] {
     anyOf = try OpenAPIAnyOfType(load: map)
 }

 else if map[Self.ALLOF_KEY] is [Any] {
     allOf = try OpenAPIAllOfType(load: map)
 }
 if let xmlMap = map[Self.XML_KEY] as? StringDictionary {
     xml = try OpenAPIXMLObject(xmlMap)
 }
 switch type {
 case "array":
     arrayType = try OpenAPIArrayType(load: map)
 case "object":
     objectType = try OpenAPIObjectType(load: map)
 case "string":
     stringType = try OpenAPIStringType(load: map)
 case "integer":
     integerType = try OpenAPIIntegerType(load: map)
 case "number":
     numberType = try OpenAPIDoubleType(load: map)
 case "boolean":
     booleanType = try OpenAPIBooleanType(load: map)
 default:
     break
 }
 */
