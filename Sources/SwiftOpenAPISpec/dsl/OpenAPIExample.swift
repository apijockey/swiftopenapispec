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
//  Created by Patric Dubois on 27.03.24.
//

import Foundation

public struct OpenAPIExample : KeyedElement, RefPointerNavigable {
    public static let SUMMARY_KEY = "summary"
    public static let DESCRIPTION_KEY = "description"
    public static let VALUE_KEY = "value"
    public static let DATA_VALUE_KEY = "dataValue"
    public static let EXTERNAL_VALUE_KEY = "externalValue"
    public static let SERIALIZED_VALUE_KEY = "serializedValue"
    public init(value : JSONValue) {
        self.value = value
    }
    public init(load map: StringDictionary, diagnostics: inout [Diagnostic],pointer : String) throws {
        if case let .string(refKey) = map[OpenAPISchemaReference.REF_KEY]{
            self.ref = OpenAPISchemaReference(ref: refKey)
        }
        
        self.summary = map.readIfPresent(Self.SUMMARY_KEY, valueType: String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.SUMMARY_KEY))
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, valueType: String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.DESCRIPTION_KEY))
        self.value = map[Self.VALUE_KEY]
        self.externalValue = map.readIfPresent(Self.EXTERNAL_VALUE_KEY, valueType: String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.EXTERNAL_VALUE_KEY))

        self.serializedValue = map.readIfPresent(Self.SERIALIZED_VALUE_KEY,valueType: String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.SERIALIZED_VALUE_KEY))
        self.dataValue = map[Self.DATA_VALUE_KEY]
        // Validate unsupported keys (excluding extensions as they are dynamic)
        let supportingElments = Set(Self.supportedKeys)
        diagnostics.append(contentsOf: map.diagnoseUnsupportedElements(supportedKeys: supportingElments , pointer: pointer))
        
    }
    
    /// The set of keys supported by OpenAPI Example object (excluding dynamic extensions and $ref)
    private static var supportedKeys: Set<String> {
        [
            Self.SUMMARY_KEY,
            Self.DESCRIPTION_KEY,
            Self.VALUE_KEY,
            Self.EXTERNAL_VALUE_KEY,
            OpenAPISchemaReference.REF_KEY,
            Self.SERIALIZED_VALUE_KEY,
            Self.DATA_VALUE_KEY
        ]
    }
   
    public func element(for segmentName: String) throws -> NavigationResult {
        switch segmentName {
        case Self.SUMMARY_KEY: return .value(JSONValue(self.summary))
        case Self.DESCRIPTION_KEY: return .value(JSONValue(self.description))
        case Self.VALUE_KEY: return .value(self.value)
        case Self.EXTERNAL_VALUE_KEY: return .value(JSONValue(self.externalValue))
        case OpenAPISchemaReference.REF_KEY: return .reference(ref?.reference)
        default:
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIExample", segmentName)
        }
    }
    public var key : String?
    public var summary : String? = nil
    public var description : String? = nil
    public var value : JSONValue? = nil
    public var dataValue :JSONValue? = nil
    public var serializedValue : String?
    public var externalValue : String? = nil
    public var ref : OpenAPISchemaReference? = nil
  
   
}
