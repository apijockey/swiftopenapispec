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

/*
 * Copyright 2025 
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

//
//  File.swift
//
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation

public struct OpenAPIMediaType :  KeyedElement , PointerNavigable {
    public static let SCHEMA_KEY = "schema"
    public static let ITEM_SCHEMA_KEY = "itemSchema"
    public static let EXAMPLES_KEY = "examples"
    public static let EXAMPLE_KEY = "example"
    public static let ENCODING_KEY = "encoding"
    public static let PREFIX_ENCODING_KEY = "prefixEncoding"
    public static let ITEM_ENCODING_KEY = "itemEncoding"
    public static let EXTENSIONS_KEY = "extensions"
    public var key : String?
    public init(load map: StringDictionary,_ diagnostics: inout [Diagnostic]) throws {
            if let ref  =  try map.readIfPresent(OpenAPISchemaReference.REF_KEY, objectType: OpenAPISchemaReference.self) {
                self.ref = ref
                return
            }
        self.schema = try map.readIfPresent(Self.SCHEMA_KEY, objectType: OpenAPISchema.self)
        self.examples = try map.mapListIfPresent(Self.EXAMPLES_KEY, objectType: OpenAPIExample.self)
        self.encoding =  try map.mapListIfPresent(Self.ENCODING_KEY, objectType: OpenAPIEncoding.self)
        self.prefixEncoding = try map.mapListIfPresent(Self.PREFIX_ENCODING_KEY, objectType: OpenAPIEncoding.self)
        self.itemEncoding =  try map.mapListIfPresent(Self.ITEM_ENCODING_KEY, objectType: OpenAPIEncoding.self)
    }
   

    public func element(for segmentName: String) throws -> NavigationResult {
        switch segmentName {
        case Self.SCHEMA_KEY:
            return .navigable(self.schema)
        case Self.EXAMPLES_KEY:
            return try self.examples.element(for: segmentName)
        case Self.ENCODING_KEY: return try encoding.element(for: segmentName)
        case Self.PREFIX_ENCODING_KEY: return try prefixEncoding.element(for: segmentName)
        case Self.ITEM_ENCODING_KEY: return try itemEncoding.element(for: segmentName)
        case OpenAPISchemaReference.REF_KEY: return .reference(ref?.reference)
        default:
            if self.key == segmentName { return .navigable(self.schema) }
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIMediaType", segmentName)
        }
    }
    public var schema : OpenAPISchema? = nil
    public var itemSchema : OpenAPISchema? = nil
    public var examples : [OpenAPIExample] = []
   
    public var encoding :[OpenAPIEncoding] = []
    public var prefixEncoding :[OpenAPIEncoding] = []
    public var itemEncoding :[OpenAPIEncoding] = []
    public var ref : OpenAPISchemaReference? = nil
    //ENCODING
}

