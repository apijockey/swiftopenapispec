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

//  Created by Patric Dubois on 10.12.25.
//

public struct OpenAPIDiscriminator :  ThrowingHashMapInitiable, PointerNavigable {
   
    
    public func element(for segmentName: String) throws -> NavigationResult {
        switch segmentName {
        case Self.PROPERTY_NAME_KEY: return .value(JSONValue(propertyName))
        case Self.MAPPING_KEY:
            let value = try JSONValue(mapping)
            return .value(value)
        case Self.DEFAULT_MAPPING_KEY: return .value(JSONValue(defaultMapping))
        default: throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIDiscriminator", segmentName)
        }
    }
    
    
    
    public static let PROPERTY_NAME_KEY = "propertyName"
    public static let MAPPING_KEY = "mapping"
    public static let DEFAULT_MAPPING_KEY = "defaultMapping"
    
    
    
    public init(load map: StringDictionary, diagnostics: inout [Diagnostic],pointer : String) throws {
        self.propertyName = map.readIfPresent(Self.PROPERTY_NAME_KEY, valueType: String.self, diagnostics : &diagnostics, pointer: pointer)
        if case let .object(mappings) = map[Self.MAPPING_KEY] {
            
            for mapping in mappings {
                if case let .string(value) = mapping.value {
                    self.mapping[mapping.key] = value
                }
            }
        }
        self.defaultMapping = map.readIfPresent(Self.DEFAULT_MAPPING_KEY, valueType: String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.DEFAULT_MAPPING_KEY))
        
    }
    
    public var propertyName: String?
    public var mapping =  Dictionary<String, String>()
    public var defaultMapping: String?
    
}
