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

public struct OpenAPIHeader :  KeyedElement, PointerNavigable {

    public static let ALLOW_EMPTYVALUE_KEY = "allowEmptyValue"
    public static let ALLOW_RESERVED_KEY = "allowReserved"
    public static let CONTENT_KEY = "content"
    public static let DESCRIPTION_KEY = "description"
    public static let DEPRECATED_KEY = "deprecated"
    public static let EXAMPLE_KEY = "example"
    public static let EXAMPLES_KEY = "examples"
    public static let EXTENSIONS_KEY = "extensions"
    public static let EXPLODE_KEY = "explode"
    public static let REQUIRED_KEY = "required"
    public static let SCHEMA_KEY = "schema"
    public static let STYLE_KEY = "style"
   
    public init(load map: StringDictionary,_ diagnostics: inout [Diagnostic]) throws {
        if let ref  =  try map.readIfPresent(OpenAPISchemaReference.REF_KEY, objectType: OpenAPISchemaReference.self) {
            self.ref = ref
            return
        }
        
        self.description =  map.readIfPresent(Self.DESCRIPTION_KEY, valueType: String.self)
        self.deprecated =  map.readIfPresent(Self.DEPRECATED_KEY, valueType: Bool.self)
        self.allowEmptyValue = map.readIfPresent(Self.ALLOW_EMPTYVALUE_KEY, valueType: Bool.self)
       
        self.explode = map.readIfPresent(Self.EXPLODE_KEY, valueType: Bool.self)
        self.allowReserved = map.readIfPresent(Self.ALLOW_RESERVED_KEY,valueType:  Bool.self)
        self.example = map.readIfPresent(Self.EXAMPLE_KEY,valueType:  String.self)
        
        self.examples  = try map.mapListIfPresent(Self.EXAMPLES_KEY, objectType: OpenAPIExample.self)
        self.content = try map.readIfPresent(Self.CONTENT_KEY,objectType:  OpenAPIMediaType.self)
        extensions = try OpenAPIExtension.extensionElements(map)
     
       
        self.required = map.readIfPresent(Self.REQUIRED_KEY, valueType: Bool.self) ?? false
        self.schema = try map.readIfPresent(Self.SCHEMA_KEY, objectType: OpenAPISchema.self)
       
        self.style = map.readIfPresent(Self.STYLE_KEY, valueType: String.self)
       
    }
   

    public func element(for segmentName: String) throws -> NavigationResult {
       switch segmentName {
       case Self.ALLOW_EMPTYVALUE_KEY: return .value(JSONValue(allowEmptyValue))
       case Self.ALLOW_RESERVED_KEY: return .value(JSONValue(allowReserved))
       case Self.CONTENT_KEY: return .navigable(content)
       
       case Self.EXAMPLE_KEY: return .value(JSONValue(example))
       case Self.EXAMPLES_KEY: return try examples.element(for: segmentName)
       case Self.EXPLODE_KEY: return .value(JSONValue(explode))
       case Self.EXTENSIONS_KEY: return try extensions.element(for: segmentName)
       case Self.DESCRIPTION_KEY: return .value(JSONValue(description))
       case Self.DEPRECATED_KEY: return .value(JSONValue(deprecated))
       case Self.SCHEMA_KEY: return .navigable(schema)
       case Self.STYLE_KEY: return .value(JSONValue(style))
       case OpenAPISchemaReference.REF_KEY: return .reference(ref?.reference)
       default:
           // Für x-* Vendor Extensions einzelne Keys erlauben: "x-..." -> passenden Extension-Wert liefern
//           if segmentName.hasPrefix("x-"), let exts = extensions {
//               let ext = exts.first(where: { $0.key == segmentName }) {
//                   // Gib die strukturierte oder einfache Extension zurück
//                   //return ext.structuredExtension?.properties ?? ext.simpleExtensionValue
//               }
//           }
           throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIHeader", segmentName)
    
       
        
        }
    }
    public var key: String?
    public var required : Bool? = nil
    public var description : String? = nil
    public var deprecated : Bool? = nil
    public var allowEmptyValue : Bool? = nil
    public var schema : OpenAPISchema? = nil
    public var style : String? = nil
    public var explode : Bool? = nil
    public var ref : OpenAPISchemaReference? = nil
    public var allowReserved : Bool? = nil
    public var example :(any Sendable)? = nil
    public var extensions : [OpenAPIExtension] = []
    public var examples : [OpenAPIExample] = []
    public var content : OpenAPIMediaType? = nil
 
   
    //TODO: Examples Object
   
}

