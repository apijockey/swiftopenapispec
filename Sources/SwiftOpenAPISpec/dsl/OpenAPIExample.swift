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

public struct OpenAPIExample : KeyedElement, PointerNavigable,OpenAPISchemaReferenceable {
    public static let SUMMARY_KEY = "summary"
    public static let DESCRIPTION_KEY = "description"
    public static let VALUE_KEY = "value"
 
    public static let EXTERNAL_VALUE_KEY = "externalValue"
    public static let SERIALIZED_VALUE_KEY = "serializedValue"
    public init(load map: [String : Any]) throws {
        if let ref  =  try OpenAPISchemaReference.initReference(from: (map)) {
            self.ref = ref
            return
        }
        self.summary = map.readIfPresent(Self.SUMMARY_KEY, String.self)
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
        self.value = map[Self.VALUE_KEY].stringifyValue
        self.externalValue = map.readIfPresent(Self.EXTERNAL_VALUE_KEY, String.self)
       
       
       
        self.serializedValue = map[Self.SERIALIZED_VALUE_KEY].stringifyValue
    }
    public static func initialize(_ map: StringDictionary) throws ->  InitializationResult<Self> {
        let element = try Self(load: map)
        return InitializationResult(value: element, diagnostics: [])
    }
    public func element(for segmentName: String) throws -> Any? {
        switch segmentName {
        case Self.SUMMARY_KEY: return self.summary
        case Self.DESCRIPTION_KEY: return self.description
        case Self.VALUE_KEY: return self.value
        case Self.EXTERNAL_VALUE_KEY: return self.externalValue
        case OpenAPISchemaReference.REF_KEY: return self.ref
        default:
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIExample", segmentName)
        }
    }
    public var key : String?
    public var summary : String? = nil
    public var description : String? = nil
    public var value : String? = nil
    public var dataValue :Data? = nil
    public var serializedValue : String?
    public var externalValue : String? = nil
    public var ref : OpenAPISchemaReference? = nil
  
   
}
