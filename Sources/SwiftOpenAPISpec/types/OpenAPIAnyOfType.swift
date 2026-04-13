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


public struct OpenAPIAnyOfType : OpenAPISchemaType, PointerNavigable, Equatable, Hashable {
    
   
    
    public var ref: OpenAPISchemaReference? { nil}
    public static let DISCRIMINATOR_KEY = "discriminator"
    public static let TYPE_KEY = "anyOf"
   
    public init(types :[OpenAPISchema]) {
        self.items = types
        self.type = "anyOf"
    }
    
  
    public init(load map: StringDictionary,_ diagnostics: inout [Diagnostic], pointer : String) throws {
        if case .array = map[Self.TYPE_KEY] {
            self.type = "array"
        }
        else {
            self.type = "unknown"
           
        }
        self.items = try map.mapListIfPresent("anyOf", objectType: OpenAPISchema.self, diagnostics: &diagnostics, pointer: pointer)
    }
    
   
    public func element(for segmentName: String) throws -> NavigationResult {
        if let index = Int(segmentName) {
            return .navigable(self.items?[index])
        }
        if segmentName ==  OpenAPISchemaReference.REF_KEY {
            return .reference(ref?.reference)
        }
        if segmentName == OpenAPISchemaReference.REF_KEY {
            if let reference = ref {
                return .reference(reference.refString)
                
            }
            else {
                throw OpenAPISpecification.Errors.notFound(segmentName)
            }
        }
        throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIAnyOfType",segmentName)
    }
    public static var supportedKeys: [String] {
        return [OpenAPISchemaReference.REF_KEY]
    }
    public let type : String?
    public var items: [OpenAPISchema]?
   
    
}
