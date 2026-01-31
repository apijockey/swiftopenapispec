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
            case Self.EXAMPLE_KEY : return .navigable(example)
        case Self.EXCLUSIVE_MAXIMUM_KEY : return .value(JSONValue(bool: exclusiveMaximum))
        case Self.FORMAT_KEY : return .value(JSONValue(string: format))
        case OpenAPISchemaReference.REF_KEY :
            if case let .ref(reference) = self.type {
                return .reference(reference.refString)
                
            }
            else {
                throw OpenAPISpecification.Errors.notFound(segmentName)
            }
        case Self.MULTIPLEOF_KEY : return .value(JSONValue(double: multipleOf))
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
    public static let WRITE_ONLY_KEY = "readOnly"
    
   
    public static let MAX_PROPERTIES_KEY = "maxProperties"
    public static let MIN_PROPERTIES_KEY = "minProperties"
    
    
    
    public static let PATTERN_KEY = "pattern"
    public static let TYPE_KEY = "type"
    public static let TITLE_KEY = "title"
    
    public static let REQUIRED_KEY = "required"
    
    public init(load map: StringDictionary, _ diagnostics: inout [Diagnostic]) throws {
       
        self.defaultValue =  map[Self.DEFAULT_VALUE_KEY]
        self.deprecated = map.readIfPresent(Self.DEPRECATED_KEY, valueType:  Bool.self)
        self.discriminator = try map.readIfPresent(Self.DISCRIMINATOR_KEY,  objectType:  OpenAPIDiscriminator.self)
        // Value MUST be a string. Multiple types via an array are not supported.
       
            self.type = try OpenAPIType(load: map,  &diagnostics)
       
       
        
        if case let .array(allowedElements)  = map[Self.ALLOWED_ELEMENTS_KEY]  {
            var collected: Set<String> = []
            for value in allowedElements {
                if case let .string(text) = value {
                    collected.insert(text)
                }
            }
            self.allowedValues = collected.isEmpty ? nil : collected
        } else {
            self.allowedValues = nil
        }
        self.extensions = try OpenAPIExtension.extensionElements(map, &diagnostics)
        self.exclusiveMinimum = map.readIfPresent(Self.EXCLUSIVE_MINIMUM_KEY, valueType:  Bool.self)
        self.externalDocs = try map.readIfPresent(Self.EXAMPLE_KEY, objectType: OpenAPIExternalDocumentation.self)
        self.example = try map.readIfPresent(Self.EXAMPLE_KEY, objectType: OpenAPIExample.self)
        self.exclusiveMaximum = map.readIfPresent(Self.EXCLUSIVE_MAXIMUM_KEY, valueType:  Bool.self)
        self.format = map.readIfPresent(Self.FORMAT_KEY, valueType:  String.self)
        self.multipleOf = map.readIfPresent(Self.TYPE_KEY, valueType:Double.self)
        self.maximum = map.readIfPresent(Self.MAXIMUM_KEY, valueType:  Double.self)
        self.minimum = map.readIfPresent(Self.MINIMUM_KEY, valueType:  Double.self)
        self.maxContains = map.readIfPresent(Self.MAX_CONTAINS_KEY, valueType:  Int.self)
        self.minContains = map.readIfPresent(Self.MIN_CONTAINS_KEY, valueType:  Int.self)
        self.maxProperties = map.readIfPresent(Self.MAX_PROPERTIES_KEY, valueType:  Int.self)
        self.maxLength = map.readIfPresent(Self.MAX_LENGTH_KEY,valueType:  Int.self)
        self.minLength = map.readIfPresent(Self.MIN_LENGTH_KEY,valueType: Int.self)
        self.minProperties = map.readIfPresent(Self.MIN_PROPERTIES_KEY, valueType:  Int.self)
        self.maxItems = map.readIfPresent(Self.MAX_ITEMS_KEY, valueType:  Int.self)
        self.minItems = map.readIfPresent(Self.MIN_ITEMS_KEY, valueType:  Int.self)
        self.nullable = map.readIfPresent(Self.NULLABLE_KEY, valueType:  Bool.self)
        self.pattern = map.readIfPresent(Self.PATTERN_KEY,valueType:String.self)
        self.readOnly = map.readIfPresent(Self.READ_ONLY_KEY, valueType:  Bool.self)
        self.required = map.readListIfPresent(Self.REQUIRED_KEY, valueType:  String.self)
        
        self.title = map.readIfPresent(OpenAPISchema.TYPE_KEY, valueType:String.self)
       
        self.uniqueItems = map.readIfPresent(Self.UNIQUE_ITEMS_KEY, valueType:  Bool.self)
        self.writeOnly = map.readIfPresent(Self.WRITE_ONLY_KEY, valueType:  Bool.self)
        self.xml =  try map.readIfPresent(Self.EXAMPLE_KEY, objectType: OpenAPIXMLObject.self)
        
    }
    public static func initialize(_ map: StringDictionary) throws -> InitializationResult<OpenAPISchema> {
        var diagnostics: [Diagnostic] = []
        var openAPISchema: OpenAPISchema = try .init(load: map, &diagnostics)
        return InitializationResult(value: openAPISchema, diagnostics: [])
    }
         //self.format30 = map.readIfPresent(Self.FORMAT_KEY, String.self)
         //extensions = try OpenAPIExtension.extensionElements(map)
    
    public var allowedValues: Set<String>?
    public var defaultValue : JSONValue?
    public var deprecated: Bool?
    public var discriminator: OpenAPIDiscriminator?
  
    
    public var extensions: [OpenAPIExtension]?
    public var exclusiveMinimum: Bool?
    public var externalDocs: OpenAPIExternalDocumentation?
    public var example: OpenAPIExample?
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
