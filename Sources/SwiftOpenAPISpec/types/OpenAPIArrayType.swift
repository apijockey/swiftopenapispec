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


public struct OpenAPIArrayType : OpenAPIValidatableSchemaType, PointerNavigable{
    public static func == (lhs: OpenAPIArrayType, rhs: OpenAPIArrayType) -> Bool {
        // 1) einfache skalare Felder vergleichen
        guard lhs.type == rhs.type,
              lhs.maxItems == rhs.maxItems,
              lhs.minItems == rhs.minItems,
              lhs.uniqueItems == rhs.uniqueItems,
              lhs.maxContains == rhs.maxContains,
              lhs.minContains == rhs.minContains
        else { return false }

        // 2) items (Existential) über isEqual(to:) vergleichen
        switch (lhs.items, rhs.items) {
        case (nil, nil):
            return true
        case let (li?, ri?):
            
                return true

        default:
            return false
        }
    }
    
    public func element(for segmentName: String) throws -> Any? {
        switch segmentName {
        case Self.ITEMS_KEY: return self.items
        case Self.ARRAY_TYPE_KEY: return self.type
        case Self.MAX_ITEMS_KEY : return maxItems
        case Self.MIN_ITEMS_KEY : return minItems
        case Self.UNIQE_ITEMS_KEY : return uniqueItems
        case Self.MAX_CONTAINS_KEY : return maxContains
        case Self.MIN_CONTAINS_KEY : return minContains
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
    
    public init(_ map: [String : Any]) throws {
        self.type = map[Self.TYPE_KEY] as? String
        self.minItems = map[Self.MIN_ITEMS_KEY] as? Int
        self.maxItems = map[Self.MAX_ITEMS_KEY] as? Int
        self.maxContains = map[Self.MAX_CONTAINS_KEY] as? Int
        self.minContains = map[Self.MIN_CONTAINS_KEY] as? Int
        self.uniqueItems = map[Self.UNIQE_ITEMS_KEY] as? Bool
         if let list = (map[Self.ITEMS_KEY] as? StringDictionary),
            let type = list[Self.TYPE_KEY] as? String,
            let validatableType = OpenAPISchemaType.validatableType(type) {
                self.items = try validatableType.init(list)
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
    public var items: (any OpenAPIValidatableSchemaType)?
    
    public var ref: OpenAPISchemaReference? { nil}
}

