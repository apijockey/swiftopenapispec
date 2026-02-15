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
    public init(load map: StringDictionary,diagnostics: inout [Diagnostic],pointer : String) throws {
        if case let .string(refKey) = map[OpenAPISchemaReference.REF_KEY]{
                    self.ref = OpenAPISchemaReference(ref: refKey)
            return
        }
        self.schema = try map.readIfPresent(Self.SCHEMA_KEY, objectType: OpenAPISchema.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.SCHEMA_KEY))
        self.examples = try map.mapListIfPresent(Self.EXAMPLES_KEY, objectType: OpenAPIExample.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.EXAMPLES_KEY))
        if let exampleValue = map[Self.EXAMPLE_KEY] {
            self.example =  OpenAPIExample(value: exampleValue)
        }
        
        self.encoding =  try map.mapListIfPresent(Self.ENCODING_KEY, objectType: OpenAPIEncoding.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.ENCODING_KEY))
        self.prefixEncoding = try map.mapListIfPresent(Self.PREFIX_ENCODING_KEY, objectType: OpenAPIEncoding.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.PREFIX_ENCODING_KEY))
        self.itemEncoding =  try map.mapListIfPresent(Self.ITEM_ENCODING_KEY, objectType: OpenAPIEncoding.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.ITEM_ENCODING_KEY))
    }
   

    public func element(for segmentName: String) throws -> NavigationResult {
        switch segmentName {
        case Self.SCHEMA_KEY:
            return .navigable(self.schema)
        case Self.EXAMPLES_KEY:
            return  .navigableCollection(self.examples)
        case Self.ENCODING_KEY:return .navigableCollection(encoding)
        case Self.PREFIX_ENCODING_KEY: return  .navigableCollection(prefixEncoding)
        case Self.ITEM_ENCODING_KEY: return .navigableCollection(itemEncoding)
        case OpenAPISchemaReference.REF_KEY: return .reference(ref?.reference)
        default:
            if self.key == segmentName { return .navigable(self.schema) }
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIMediaType", segmentName)
        }
    }
    public var schema : OpenAPISchema? = nil
    public var itemSchema : OpenAPISchema? = nil
    public var examples : [OpenAPIExample] = []
    public var example : OpenAPIExample?
    public var encoding :[OpenAPIEncoding] = []
    public var prefixEncoding :[OpenAPIEncoding] = []
    public var itemEncoding :[OpenAPIEncoding] = []
    public var ref : OpenAPISchemaReference? = nil
    //ENCODING
}

