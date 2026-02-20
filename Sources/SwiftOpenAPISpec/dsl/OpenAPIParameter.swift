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


/// A structure representing a parameter in an OpenAPI operation.
///
/// `OpenAPIParameter` defines a single parameter that can be used in OpenAPI operations.
/// Parameters are uniquely identified by their name and location (query, header, path, or cookie).
///
/// Parameters describe the inputs to API operations and include metadata such as:
/// - Name and location of the parameter
/// - Data type and format
/// - Whether the parameter is required
/// - Description and examples
/// - Validation constraints
///
/// ## Parameter Locations
///
/// - `query`: Parameters in the query string (e.g., `?param=value`)
/// - `header`: Parameters in HTTP headers
/// - `path`: Parameters in the URL path (e.g., `/users/{id}`)
/// - `cookie`: Parameters in HTTP cookies
///
/// ## Example Usage
///
/// ```swift
/// // Creating a path parameter
/// let param = OpenAPIParameter(
///     name: "userId",
///     location: .path,
///     schema: OpenAPISchema(schemaType: OpenAPIStringType(format: .uuid)),
///     required: true,
///     description: "The unique identifier of the user"
/// )
/// ```
public struct OpenAPIParameter :  KeyedElement,  PointerNavigable {
    
    
    /// The location of a parameter in a request.
    ///
    /// - `cookie`: Parameter is passed in an HTTP cookie
    /// - `query`: Parameter is passed in the query string
    /// - `queryString`: Alternative name for query parameters
    /// - `header`: Parameter is passed in an HTTP header
    /// - `path`: Parameter is part of the URL path (e.g., `/users/{id}`)
    public enum ParameterLocation : String, Codable, CaseIterable, Sendable {
        case cookie, query, queryString, header ,path
    }
    
    /// The style of parameter serialization.
    ///
    /// - `simple`: Simple style (default for most locations)
    /// - `form`: Form style (used for query parameters and cookies)
    /// - `label`: Label style (used for path parameters)
    /// - `matrix`: Matrix style (used for path parameters)
    public enum ParameterStyle : String, Codable, CaseIterable, Sendable {
        case simple,form, label, matrix, spaceDelimited,pipeDelimited, deepObject
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
    public init(load map: StringDictionary,diagnostics: inout [Diagnostic],pointer : String) throws {
        
        if case let .string(refKey) = map[OpenAPISchemaReference.REF_KEY]{
            self.ref = OpenAPISchemaReference(ref: refKey)
            return
        }
        guard let location = map.readIfPresent(Self.IN_KEY,valueType:String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.IN_KEY)) else {
            throw OpenAPISpecification.Errors.invalidSpecification(OpenAPIOperation.PARAMETERS_KEY, Self.IN_KEY)
        }
        self.allowEmptyValue = map.readIfPresent(Self.ALLOW_EMPTYVALUE_KEY, valueType:  Bool.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.ALLOW_EMPTYVALUE_KEY))
        self.allowReserved = map.readIfPresent(Self.ALLOW_RESERVED_KEY, valueType: Bool.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.ALLOW_RESERVED_KEY))
        //required
        self.content = map.readIfPresent(Self.CONTENT_KEY, valueType: OpenAPIMediaType.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.CONTENT_KEY))
        self.description =  map.readIfPresent(Self.DESCRIPTION_KEY, valueType: String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.DESCRIPTION_KEY))
        self.deprecated =  map.readIfPresent(Self.DEPRECATED_KEY, valueType: Bool.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.DEPRECATED_KEY))
        self.explode = map.readIfPresent(Self.EXPLODE_KEY, valueType: Bool.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.EXPLODE_KEY))
        
        self.example = map.readIfPresent(Self.EXAMPLE_KEY, valueType: JSONValue.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.EXAMPLE_KEY))
        self.format = map.readIfPresent(Self.FORMAT_KEY, valueType: String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.FORMAT_KEY))
        
        self.examples  = try map.mapListIfPresent(Self.EXAMPLES_KEY,objectType: OpenAPIExample.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.EXAMPLES_KEY))
        extensions = try OpenAPIExtension.extensionElements(map, &diagnostics,pointer: JSONPointer.join(pointer, "extensions"))
        self.location = ParameterLocation(rawValue: location)
        
        self.name = map.readIfPresent(Self.NAME_KEY, valueType: String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.NAME_KEY))
        let required = map.readIfPresent(Self.REQUIRED_KEY,valueType: Bool.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.REQUIRED_KEY))
        self.required = required ?? false
        self.schema = try map.readIfPresent(Self.SCHEMA_KEY, objectType: OpenAPISchema.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.SCHEMA_KEY))
        if let style = map.readIfPresent(Self.STYLE_KEY, valueType: String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.STYLE_KEY)){
            self.style = style
        }
        var supportingElments = Set(Self.supportedKeys)
        supportingElments.formUnion((self.extensions ?? []).compactMap({ $0.key }))
        diagnostics.append(contentsOf: map.diagnoseUnsupportedElements(supportedKeys: supportingElments , pointer: pointer))
        
        
        
    }
    public static let supportedKeys: Set<String> = [
        FORMAT_KEY,
        NAME_KEY,
        IN_KEY,
        REQUIRED_KEY,
        DESCRIPTION_KEY,
        DEPRECATED_KEY,
        ALLOW_EMPTYVALUE_KEY,
        ALLOW_RESERVED_KEY,
        SCHEMA_KEY,
        STYLE_KEY,
        EXPLODE_KEY,
        EXAMPLE_KEY,
        EXAMPLES_KEY,
        CONTENT_KEY,
        OpenAPISchemaReference.REF_KEY,
        
    ]
   

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
           let value = JSONValue(string:style)
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
    public var style : String? = nil
    public var explode : Bool? = nil
    public var allowReserved : Bool? = nil
    public var example : JSONValue? = nil
    public var examples : [OpenAPIExample] = []
    public var content : OpenAPIMediaType? = nil
    public var format : String?
    
    public var extensions : [OpenAPIExtension]?
   
    //TODO: Examples Object
   
}
