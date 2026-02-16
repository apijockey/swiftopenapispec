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




public struct OpenAPISchema : KeyedElement, PointerNavigable {
    public var key: String?
    
    public func element(for segmentName: String) throws -> NavigationResult {
        switch segmentName {
            case Self.ALLOWED_ELEMENTS_KEY:
            let value = try JSONValue(allowedValues)
            return .value(value)
            case Self.DEFAULT_VALUE_KEY:
            
            let value = try JSONValue(defaultValue)
            return .value(value)
            case Self.DISCRIMINATOR_KEY:
            
            let value = try JSONValue(discriminator)
            return .value(value)
            case Self.EXTENSIONS_KEY :
            let value = try JSONValue(extensions)
            
            return .value(value)
        case Self.EXCLUSIVE_MINIMUM_KEY : return .value(JSONValue(bool: exclusiveMinimum))
            case OpenAPISpecification.EXTERNAL_DOCS_KEY : return .navigable(externalDocs)
            case Self.EXAMPLE_KEY : return .value(example)
        case Self.EXCLUSIVE_MAXIMUM_KEY : return .value(JSONValue(bool: exclusiveMaximum))
        case Self.FORMAT_KEY : return .value(JSONValue(string: format))
        case OpenAPISchemaReference.REF_KEY :
            if case let .ref(reference) = self.type {
                return .reference(reference.refString)
                
            }
            else {
                throw OpenAPISpecification.Errors.notFound(segmentName)
            }
        case OpenAPIOneOfType.TYPE_KEY:
            switch self.type {
                case .oneOf(let openAPIOneOfType):
                    return .navigable(openAPIOneOfType)
                case .object(let objectType):
                return .navigableCollection(objectType.properties)
            default:  throw OpenAPISpecification.Errors.notFound(segmentName)
            }
        case OpenAPIAllOfType.TYPE_KEY:
            switch self.type {
                case .allOf(let openAPIOneOfType):
                    return .navigable(openAPIOneOfType)
                default:  throw OpenAPISpecification.Errors.notFound(segmentName)
            }
        case OpenAPIAnyOfType.TYPE_KEY:
            switch self.type {
                case .anyOf(let openAPIOneOfType):
                    return .navigable(openAPIOneOfType)
                default:  throw OpenAPISpecification.Errors.notFound(segmentName)
            }
        case Self.PROPERTIES_KEY:
            switch self.type {
            case .object(let openAPIObjectType):
                   return  .navigableCollection(openAPIObjectType.properties)
            case .ref(let reference):
                return .reference(reference.reference)
            default:
                throw OpenAPISpecification.Errors.notFound(segmentName)
            }
            case Self.MULTIPLEOF_KEY : return .value(JSONValue(double: multipleOf))
            case Self.MAXIMUM_KEY : return .value(JSONValue(double: maximum))
            case Self.MAXIMUM_KEY : return .value(JSONValue(double: maximum))
            case Self.MINIMUM_KEY : return .value(JSONValue(double: minimum))
            case Self.MAX_PROPERTIES_KEY : return .value(JSONValue(int: maxProperties))
            case Self.MIN_PROPERTIES_KEY : return .value(JSONValue(int: minProperties))
            case Self.MAX_LENGTH_KEY : return .value(JSONValue(int: maxLength))
            case Self.MIN_LENGTH_KEY : return .value(JSONValue(int: maxLength))
            case Self.MAX_ITEMS_KEY : return .value(JSONValue(int: maxItems))
            case Self.MIN_ITEMS_KEY :
                return .value(JSONValue(int: minItems))
            case Self.NULLABLE_KEY :
            
            let value = try JSONValue(nullable)
            return .value(value)
        case Self.PATTERN_KEY : return .value(JSONValue(string: pattern))
        case Self.READ_ONLY_KEY :
            
            return .value(JSONValue(bool: readOnly))
            case Self.REQUIRED_KEY :
            
            let value = try JSONValue(required)
            return .value(value)
        case Self.TITLE_KEY : return .value(JSONValue(string: title))
        case Self.TYPE_KEY :
            let value = try JSONValue(type)
           return .value(value)
        case Self.UNIQUE_ITEMS_KEY :
            
            let value = try JSONValue(uniqueItems)
            return .value(value)
        case Self.XML_KEY :
            let value = try JSONValue(xml)
            return .value(value)
        case Self.WRITE_ONLY_KEY : return .value(JSONValue(bool: writeOnly))
            
        default:
            if case let .object(objectType) = self.type {
                let properties = objectType.properties
                return try properties.element(for: segmentName)
            }
            throw OpenAPISpecification.Errors.notFound(segmentName)
        }
    }
    
    public static let ALLOWED_ELEMENTS_KEY = "enum"
    public static let DEFAULT_VALUE_KEY : String = "default"
    public static let DISCRIMINATOR_KEY = "discriminator"
    public static let DEPRECATED_KEY = "deprecated"
    public static let EXAMPLE_KEY = "example"
    public static let EXTENSIONS_KEY = "extensions"
    public static let EXCLUSIVE_MAXIMUM_KEY : String = "exclusiveMaximum"
    public static let EXCLUSIVE_MINIMUM_KEY : String = "exclusiveMinimum"
    public static let FORMAT_KEY : String = "format"
    public static let DEPENDENT_REQUIRED_KEY = "dependentRequired"
    public static let DEPENDENCIES_KEY = "dependencies"
    public static let ADDITIONAL_PROPERTIES_KEY = "additionalProperties"
    public static let UNEVALUATEDPROPERTIES_KEY = "unevaluatedProperties"
    
    public static let MULTIPLEOF_KEY : String = "multipleOf"
    public static let MAXIMUM_KEY : String = "maximum"
    public static let MINIMUM_KEY : String = "minimum"
    public static let MAX_CONTAINS_KEY : String = "maxContains"
    public static let MIN_CONTAINS_KEY : String = "minContains"
    public static let NULLABLE_KEY : String = "nullable"
    public static let UNIQUE_ITEMS_KEY = "uniqueItems"
    public static let XML_KEY = "xml"
    public static let MAX_LENGTH_KEY = "maxLength"
    public static let MIN_LENGTH_KEY = "minLength"
    
    public static let MAX_ITEMS_KEY = "maxItems"
    public static let MIN_ITEMS_KEY = "minItems"
    
    public static let READ_ONLY_KEY = "readOnly"
    public static let WRITE_ONLY_KEY = "writeOnly"
    public static let PATTERNPROPERTIES_KEY = "patternProperties"
    public static let PROPERTIES_KEY = "properties"
    public static let MAX_PROPERTIES_KEY = "maxProperties"
    public static let MIN_PROPERTIES_KEY = "minProperties"
    public static let PATTERN_KEY = "pattern"
    public static let TYPE_KEY = "type"
    public static let TITLE_KEY = "title"
    public static let REQUIRED_KEY = "required"
    
    
    
    
    public init(load map: StringDictionary,  diagnostics: inout [Diagnostic],pointer : String) throws {
       
        self.defaultValue =  map[Self.DEFAULT_VALUE_KEY]
        self.deprecated = map.readIfPresent(Self.DEPRECATED_KEY, valueType:  Bool.self, diagnostics : &diagnostics, pointer: pointer)
        self.discriminator = try map.readIfPresent(Self.DISCRIMINATOR_KEY,  objectType:  OpenAPIDiscriminator.self, diagnostics: &diagnostics, pointer: pointer)
       
        self.type = try OpenAPIType(load: map,  diagnostics: &diagnostics, pointer: pointer)
       
       
        
        if case let .array(allowedElements)  = map[Self.ALLOWED_ELEMENTS_KEY]  {
            var collected: [JSONValue] = []
            for (index,value) in allowedElements.enumerated() {
                switch value {
                case .object:
                    diagnostics.append(.init(severity: .warning, code: .schemaViolation, message: "for enums, object elements are not suported, only only primitive types (String, Number, Boolean, Null, Integer)", pointer: JSONPointer.join(JSONPointer.join(pointer, "enum"),String(index)),rule: "OAS30.EnumAllowedValues"))
                case .array:
                    diagnostics.append(.init(severity: .warning, code: .schemaViolation, message: "for enums, array elements are not suported, only only primitive types (String, Number, Boolean, Null, Integer)", pointer: JSONPointer.join(JSONPointer.join(pointer, "enum"),String(index)),rule: "OAS30.EnumAllowedValues"))
                case .string:
                    if case .string = type {
                        collected.append(value)
                    }
                    else {
                        diagnostics.append(.init(severity: .warning, code: .schemaViolation, message: "mixed elements are not suported and must match the schema type '\(self.type.debugDescription)', got: '\(value.debugDescription)'", pointer: JSONPointer.join(JSONPointer.join(pointer, "enum"),String(index)),rule: "OAS30.EnumAllowedValues"))
                    }
                case .number:
                    if case .number = type {
                        collected.append(value)
                    }
                    else {
                        diagnostics.append(.init(severity: .warning, code: .schemaViolation, message: "mixed elements are not suported and must match the schema type '\(self.type.debugDescription)', got: '\(value.debugDescription)'", pointer: JSONPointer.join(JSONPointer.join(pointer, "enum"),String(index)),rule: "OAS30.EnumAllowedValues"))
                    }
                case .integer:
                    if case .number = type{
                        collected.append(value)
                    }
                    else if case .integer = type {
                        collected.append(value)
                    }
                    else {
                        diagnostics.append(.init(severity: .warning, code: .schemaViolation, message: "mixed elements are not suported and must match the schema type '\(self.type.debugDescription)', got: '\(value.debugDescription)'", pointer: JSONPointer.join(JSONPointer.join(pointer, "enum"),String(index)),rule: "OAS30.EnumAllowedValues"))
                    }
                case .boolean:
                    if case .bool = type {
                        collected.append(value)
                    }
                    else {
                        diagnostics.append(.init(severity: .warning, code: .schemaViolation, message: "mixed elements are not suported and must match the schema type '\(self.type.debugDescription)', got: '\(value.debugDescription)'", pointer: JSONPointer.join(JSONPointer.join(pointer, "enum"),String(index)),rule: "OAS30.EnumAllowedValues"))
                    }
                case .null:
                    if self.nullable == false {
                        diagnostics.append(.init(severity: .warning, code: .schemaViolation, message: "nullable is set to 'false', 'null' is not an allowed value", pointer: JSONPointer.join(JSONPointer.join(pointer, "enum"),value.debugDescription),rule: "OAS30.EnumAllowedValues"))
                    }
                }
            }
            
            self.allowedValues = collected
        } else {
            self.allowedValues = []
        }
        self.extensions = try OpenAPIExtension.extensionElements(map, &diagnostics,pointer: JSONPointer.join(pointer, "extensions"))
        self.exclusiveMinimum = map.readIfPresent(Self.EXCLUSIVE_MINIMUM_KEY, valueType:  Bool.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.EXCLUSIVE_MINIMUM_KEY))
        self.externalDocs = try map.readIfPresent(Self.EXAMPLE_KEY, objectType: OpenAPIExternalDocumentation.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.EXAMPLE_KEY))
        self.example  = map[Self.EXAMPLE_KEY]
        self.exclusiveMaximum = map.readIfPresent(Self.EXCLUSIVE_MAXIMUM_KEY, valueType:  Bool.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.EXCLUSIVE_MAXIMUM_KEY))
        self.format = map.readIfPresent(Self.FORMAT_KEY, valueType:  String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.FORMAT_KEY))
        self.multipleOf = map.readIfPresent(Self.MULTIPLEOF_KEY, valueType:Double.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.MULTIPLEOF_KEY))
        self.maximum = map.readIfPresent(Self.MAXIMUM_KEY, valueType:  Double.self, diagnostics : &diagnostics, pointer:JSONPointer.join(pointer, Self.MAXIMUM_KEY))
        self.minimum = map.readIfPresent(Self.MINIMUM_KEY, valueType:  Double.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.MINIMUM_KEY))
        self.maxContains = map.readIfPresent(Self.MAX_CONTAINS_KEY, valueType:  Int.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.MAX_CONTAINS_KEY))
        self.minContains = map.readIfPresent(Self.MIN_CONTAINS_KEY, valueType:  Int.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.MIN_CONTAINS_KEY))
        self.maxProperties = map.readIfPresent(Self.MAX_PROPERTIES_KEY, valueType:  Int.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.MAX_PROPERTIES_KEY))
        self.maxLength = map.readIfPresent(Self.MAX_LENGTH_KEY,valueType:  Int.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.MAX_LENGTH_KEY))
        self.minLength = map.readIfPresent(Self.MIN_LENGTH_KEY,valueType: Int.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.MIN_LENGTH_KEY))
        self.minProperties = map.readIfPresent(Self.MIN_PROPERTIES_KEY, valueType:  Int.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.MIN_PROPERTIES_KEY))
        self.maxItems = map.readIfPresent(Self.MAX_ITEMS_KEY, valueType:  Int.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.MAX_ITEMS_KEY))
        self.minItems = map.readIfPresent(Self.MIN_ITEMS_KEY, valueType:  Int.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.MIN_ITEMS_KEY))
        self.nullable = map.readIfPresent(Self.NULLABLE_KEY, valueType:  Bool.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.NULLABLE_KEY))
        self.pattern = map.readIfPresent(Self.PATTERN_KEY,valueType:String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.PATTERN_KEY))
        self.readOnly = map.readIfPresent(Self.READ_ONLY_KEY, valueType:  Bool.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.READ_ONLY_KEY))
        self.required = map.readListIfPresent(Self.REQUIRED_KEY, valueType:  String.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.REQUIRED_KEY))
    
        self.title = map.readIfPresent(OpenAPISchema.TYPE_KEY, valueType:String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, OpenAPISchema.TYPE_KEY))
       
        self.uniqueItems = map.readIfPresent(Self.UNIQUE_ITEMS_KEY, valueType:  Bool.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.UNIQUE_ITEMS_KEY))
        self.writeOnly = map.readIfPresent(Self.WRITE_ONLY_KEY, valueType:  Bool.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.WRITE_ONLY_KEY))
        self.xml =  try map.readIfPresent(Self.EXAMPLE_KEY, objectType: OpenAPIXMLObject.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.EXAMPLE_KEY))
    }
    public static var supportedKeys: Set<String>      {
        return [
            ALLOWED_ELEMENTS_KEY,
            DEFAULT_VALUE_KEY,
            DISCRIMINATOR_KEY,
            DEPRECATED_KEY,
            EXAMPLE_KEY,
            EXTENSIONS_KEY,
            OpenAPISchemaReference.REF_KEY,
            EXCLUSIVE_MAXIMUM_KEY,
            EXCLUSIVE_MINIMUM_KEY,
            FORMAT_KEY,
            MULTIPLEOF_KEY,
            MAXIMUM_KEY,
            MINIMUM_KEY,
            MAX_CONTAINS_KEY,
            MIN_CONTAINS_KEY,
            NULLABLE_KEY,
            UNIQUE_ITEMS_KEY,
            XML_KEY,
            MAX_LENGTH_KEY,
            MIN_LENGTH_KEY,
            MAX_ITEMS_KEY,
            MIN_ITEMS_KEY,
            READ_ONLY_KEY,
            WRITE_ONLY_KEY,
            PROPERTIES_KEY,
            MAX_PROPERTIES_KEY,
            MIN_PROPERTIES_KEY,
            PATTERN_KEY,
            TYPE_KEY,
            TITLE_KEY,
            REQUIRED_KEY
        ]
    }
    
    
   
   
         //self.format30 = map.readIfPresent(Self.FORMAT_KEY, String.self)
         //extensions = try OpenAPIExtension.extensionElements(map)
    
    public var allowedValues: [JSONValue]
    public var defaultValue : JSONValue?
    public var deprecated: Bool?
    public var discriminator: OpenAPIDiscriminator?
  
    
    public var extensions: [OpenAPIExtension]?
    public var exclusiveMinimum: Bool?
    public var externalDocs: OpenAPIExternalDocumentation?
    public var example: JSONValue?
    public var exclusiveMaximum: Bool?
    
    public var format: String?
    
    public var multipleOf: Double?
    public var maximum: Double?
    public var minimum: Double?
    public var maxContains: Int?
    public var minContains: Int?
    public var maxProperties: Int?
    public var maxLength: Int?
    public var minLength: Int?
    public var minProperties: Int?
    public var maxItems: Int?
    public var minItems: Int?
    public var nullable: Bool?
    public var pattern: String?
    public var readOnly: Bool?
    public var required: [String]?
    
    public var title : String?
    public var type : OpenAPIType?
    public var uniqueItems: Bool?
    public var writeOnly: Bool?
    public var xml : OpenAPIXMLObject?
  
    
  
    
    
}
