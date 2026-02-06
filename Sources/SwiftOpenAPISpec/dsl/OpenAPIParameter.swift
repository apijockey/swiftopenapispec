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


/**
 /**
  A unique parameter is defined by a combination of a name and location.
  */
 */
public struct OpenAPIParameter :  KeyedElement,  PointerNavigable {
    
    
    public enum ParameterLocation : String, Codable, CaseIterable, Sendable {
        case cookie, query, queryString, header ,path
    }
    public enum ParameterStyle : String, Codable, CaseIterable, Sendable {
        case simple,form, label, matrix
    }
    public static let FORMAT_KEY = "format"
    public static let NAME_KEY = "name"
    
    public static let IN_KEY = "in"
    public static let REQUIRED_KEY = "required"
    public static let DESCRIPTION_KEY = "description"
    public static let DEPRECATED_KEY = "deprecated"
    public static let ALLOW_EMPTYVALUE_KEY = "allowEmptyValue"
    public static let ALLOW_RESERVED_KEY = "allowReserved"
    public static let SCHEMA_KEY = "schema"
    public static let STYLE_KEY = "style"
    public static let EXPLODE_KEY = "explode"
    public static let EXAMPLE_KEY = "example"
    public static let EXAMPLES_KEY = "examples"
    public static let CONTENT_KEY = "content"
    public init(load map: StringDictionary,diagnostics: inout [Diagnostic]) throws {
        
        if case let .string(refKey) = map[OpenAPISchemaReference.REF_KEY]{
                    self.ref = OpenAPISchemaReference(ref: refKey)
            return
        }
        guard let location = map.readIfPresent(Self.IN_KEY,valueType:String.self, diagnostics : &diagnostics) else {
            throw OpenAPISpecification.Errors.invalidSpecification(OpenAPIOperation.PARAMETERS_KEY, Self.IN_KEY)
        }
        self.allowEmptyValue = map.readIfPresent(Self.ALLOW_EMPTYVALUE_KEY, valueType:  Bool.self, diagnostics : &diagnostics)
        self.allowReserved = map.readIfPresent(Self.ALLOW_RESERVED_KEY, valueType: Bool.self, diagnostics : &diagnostics)
        //required
        self.content = map.readIfPresent(Self.CONTENT_KEY, valueType: OpenAPIMediaType.self, diagnostics : &diagnostics)
        self.description =  map.readIfPresent(Self.DESCRIPTION_KEY, valueType: String.self, diagnostics : &diagnostics)
        self.deprecated =  map.readIfPresent(Self.DEPRECATED_KEY, valueType: Bool.self, diagnostics : &diagnostics)
        self.explode = map.readIfPresent(Self.EXPLODE_KEY, valueType: Bool.self, diagnostics : &diagnostics)
       
        self.example = map.readIfPresent(Self.EXAMPLE_KEY, valueType: JSONValue.self, diagnostics : &diagnostics)
        self.format = map.readIfPresent(Self.FORMAT_KEY, valueType: String.self, diagnostics : &diagnostics)
        
        self.examples  = try map.mapListIfPresent(Self.EXAMPLES_KEY,objectType: OpenAPIExample.self, diagnostics: &diagnostics)
        extensions = try OpenAPIExtension.extensionElements(map, &diagnostics)
        self.location = ParameterLocation(rawValue: location)
      
        self.name = map.readIfPresent(Self.NAME_KEY, valueType: String.self, diagnostics : &diagnostics)
        let required = map.readIfPresent(Self.REQUIRED_KEY,valueType: Bool.self, diagnostics : &diagnostics)
        self.required = required ?? false
        self.schema = try map.readIfPresent(Self.SCHEMA_KEY, objectType: OpenAPISchema.self, diagnostics: &diagnostics)
        if let style = map.readIfPresent(Self.STYLE_KEY, valueType: String.self, diagnostics : &diagnostics) {
            self.style = ParameterStyle(rawValue: style)
        }
        
       
       
       
    }
   

    public func element(for segmentName: String) throws -> NavigationResult {
       switch segmentName {
       case Self.IN_KEY :return .value(JSONValue(location?.rawValue))
       case Self.REQUIRED_KEY :
           let value = try JSONValue(required)
           return .value(value)
       case Self.DESCRIPTION_KEY:
           let value = JSONValue(description)
           return .value(value)
       case Self.DEPRECATED_KEY:
           let value = try JSONValue(deprecated)
           return .value(value)
       case Self.ALLOW_EMPTYVALUE_KEY:
           
           return .value(JSONValue(bool: allowEmptyValue))
       case Self.ALLOW_RESERVED_KEY: return .value(JSONValue(bool: allowReserved))
       case Self.SCHEMA_KEY:
           
           return .navigable(schema)
       case Self.STYLE_KEY:
           let value = try JSONValue(style)
           return .value(value)
       case Self.EXPLODE_KEY:
           let value = try JSONValue(explode)
           return .value(value)
       case Self.EXAMPLE_KEY: return .value(example)
       case Self.EXAMPLES_KEY: return try examples.element(for: segmentName)
       case Self.CONTENT_KEY: return .navigable(content)
       case OpenAPISchemaReference.REF_KEY: return .reference(ref?.reference)
       default:
           if segmentName.hasPrefix("x-"), let exts = extensions {
                           if let ext = exts.first(where: { $0.key == segmentName }) {
                               let value = try JSONValue(ext)
                               return .value(value)
                               
                           }
                       }
           throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIParameter", segmentName)
        }
    }
    public var key: String?
    public var name: String?
    public var ref : OpenAPISchemaReference? = nil
    public var location : ParameterLocation?
    public var required : Bool? 
    public var description : String? = nil
    public var deprecated : Bool? = nil
    public var allowEmptyValue : Bool? = nil
    public var schema :  OpenAPISchema? = nil
    //https://learn.openapis.org/specification/parameters.html
    public var style : ParameterStyle? = nil
    public var explode : Bool? = nil
    public var allowReserved : Bool? = nil
    public var example : JSONValue? = nil
    public var examples : [OpenAPIExample] = []
    public var content : OpenAPIMediaType? = nil
    public var format : String?
    
    public var extensions : [OpenAPIExtension]?
   
    //TODO: Examples Object
   
}
