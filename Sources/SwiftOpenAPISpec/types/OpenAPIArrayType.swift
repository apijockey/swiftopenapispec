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


public struct OpenAPIArrayType : OpenAPISchemaType, PointerNavigable{
    public var discriminator: OpenAPIDiscriminator?
    
    
    
    
    public func element(for segmentName: String) throws -> NavigationResult {
        switch segmentName {
        case Self.ITEMS_KEY: return .navigable(self.items)
        case Self.ARRAY_TYPE_KEY: return .value(JSONValue(string: self.type))
        case Self.MAX_ITEMS_KEY : return .value(JSONValue(int: maxItems))
        case Self.MIN_ITEMS_KEY : return .value(JSONValue(int: minItems))
        case Self.UNIQE_ITEMS_KEY : return .value(JSONValue(bool: uniqueItems))
        case Self.MAX_CONTAINS_KEY : return .value(JSONValue(int: maxContains))
        case Self.MIN_CONTAINS_KEY : return .value(JSONValue(int: minContains))
        default:
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIArrayType", segmentName)
        }
    }
    
    
    public static let ARRAY_TYPE_KEY = "array"
    public static let TYPE_KEY = "type"
    public static let MAX_ITEMS_KEY = "maxItems"
    public static let ITEMS_KEY = "items"
    public static let MIN_ITEMS_KEY = "minItems"
    public static let UNIQE_ITEMS_KEY = "uniqueItems"
    public static let MAX_CONTAINS_KEY = "maxContains"
    public static let MIN_CONTAINS_KEY = "minContains"
    
    public init(load map: StringDictionary, diagnostics : inout [Diagnostic], pointer : String) throws {
        self.type = map.readIfPresent(Self.TYPE_KEY, valueType: String.self, diagnostics: &diagnostics, pointer: pointer)
        self.minItems = map.readIfPresent(Self.MIN_ITEMS_KEY, valueType: Int.self, diagnostics: &diagnostics, pointer: pointer)
        self.maxItems = map.readIfPresent(Self.MAX_ITEMS_KEY, valueType:  Int.self, diagnostics: &diagnostics, pointer: pointer)
        self.maxContains = map.readIfPresent(Self.MAX_CONTAINS_KEY, valueType : Int.self, diagnostics: &diagnostics, pointer: pointer)
        self.minContains = map.readIfPresent(Self.MIN_CONTAINS_KEY, valueType:  Int.self, diagnostics: &diagnostics, pointer: pointer)
        self.uniqueItems = map.readIfPresent(Self.UNIQE_ITEMS_KEY, valueType:  Bool.self, diagnostics: &diagnostics, pointer: pointer)
         if let list = map[Self.ITEMS_KEY] ,
            case let .object(type) = list {
             self.items = try OpenAPISchema.initialize(load: type, diagnostics : &diagnostics, pointer: pointer).value
             }
    }
   

    public func validate() throws {
        
    }
    public let type : String?
    public var maxItems : Int?
    public var minItems : Int?
    public var uniqueItems : Bool?
    public var maxContains : Int?
    public var minContains : Int?
    public var items: OpenAPISchema?
    
    
}
