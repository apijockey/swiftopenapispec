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


public struct OpenAPIAllOfType : OpenAPIValidatableSchemaType, PointerNavigable {
    public static func == (lhs: OpenAPIAllOfType, rhs: OpenAPIAllOfType) -> Bool {
        // 1) einfache Felder
        guard lhs.type == rhs.type else { return false }

        // 2) items per isEqual(to:) vergleichen (existential-sicher)
        switch (lhs.items, rhs.items) {
        case (nil, nil):
            return true
        case let (l?, r?):
            guard l.count == r.count else { return false }
            for (le, re) in zip(l, r) {
                if !le.isEqual(to: re) { return false }
            }
            return true
        default:
            return false
        }
    }
    
    public func element(for segmentName: String) throws -> Any? {
        if let index = Int(segmentName) {
            return self.items?[index]
        }
        if segmentName ==  OpenAPISchemaReference.REF_KEY {
            return ref
        }
        throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIOneOfType",segmentName)
    }
    
    public var ref: OpenAPISchemaReference?
   
    public static let TYPE_KEY = "allOf"
    public init(_ map: [String : Any]) throws {
        self.type = map[Self.TYPE_KEY] as? String
        guard let list = (map["allOf"] as? [Any]) else {
            return
        }
        self.items = try list.asValidatableSchemaType()
    }
    
    public func validate() throws {
        
    }

    public let type : String?
    public var items: [any OpenAPIValidatableSchemaType]?
  
}
