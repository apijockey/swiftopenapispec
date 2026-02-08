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


public struct OpenAPIOneOfType : OpenAPISchemaType,ThrowingHashMapInitiable, PointerNavigable {
    
    
   
    
    public func element(for segmentName: String) throws -> NavigationResult {
        if let index = Int(segmentName),
           index >= 0,
           let itemsCount = self.items?.count,
           index < itemsCount,
            let items = items {
            return .navigable (self.items?[index])
        }
        if segmentName ==  OpenAPISchemaReference.REF_KEY {
            return .reference( ref?.reference)
        }
        throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIOneOfType",segmentName)
    }
    
    
    public static let TYPE_KEY = "oneOf"
    public static let DISCRIMINATOR_KEY = "discriminator"
    

    public init(load map: StringDictionary,diagnostics: inout [Diagnostic],pointer : String) throws {
        self.type = map.readIfPresent(Self.TYPE_KEY, valueType: String.self, diagnostics : &diagnostics, pointer: pointer)
        
       
        
        self.items = try map.mapListIfPresent("oneOf",objectType: OpenAPISchema.self, diagnostics: &diagnostics, pointer : pointer)
    }
   
    public let type : String?
    public var items: [OpenAPISchema]?
  public var ref: OpenAPISchemaReference? { nil}
}
