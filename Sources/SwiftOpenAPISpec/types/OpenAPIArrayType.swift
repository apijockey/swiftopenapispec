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
//  OpenAPIDefaultSchemaType 2.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 07.12.25.
//


public struct OpenAPIArrayType : OpenAPISchemaType, PointerNavigable, Equatable, Hashable{
   
    
    
    
    
    public func element(for segmentName: String) throws -> NavigationResult {
        switch segmentName {
        case Self.ITEMS_KEY: return .navigable(self.items)
        case Self.ARRAY_TYPE_KEY: return .value(JSONValue(string: self.type))
        
        default:
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIArrayType", segmentName)
        }
    }
    
    
    public static let ARRAY_TYPE_KEY = "array"
    public static let TYPE_KEY = "type"
    public static let CONTAINS_KEY = "contains"
    public static let ITEMS_KEY = "items"
    
    
    public init(load map: StringDictionary, diagnostics : inout [Diagnostic], pointer : String) throws {
        self.type = map.readIfPresent(Self.TYPE_KEY, valueType: String.self, diagnostics: &diagnostics, pointer: pointer)
        self.contains = try map.readIfPresent(Self.TYPE_KEY, objectType: OpenAPISchema.self, diagnostics: &diagnostics, pointer: pointer)
       
         if let list = map[Self.ITEMS_KEY] ,
            case let .object(type) = list {
             self.items = try OpenAPISchema.initialize(load: type, diagnostics : &diagnostics, pointer: pointer).value
             }
    }
    public static var supportedKeys: [String] {
        return [
            ARRAY_TYPE_KEY,
            TYPE_KEY,
            CONTAINS_KEY,
            ITEMS_KEY
        ]
    }

    public func validate() throws {
        
    }
    public let type : String?
    public var items: OpenAPISchema?
    public var contains : OpenAPISchema?
    
    
}
