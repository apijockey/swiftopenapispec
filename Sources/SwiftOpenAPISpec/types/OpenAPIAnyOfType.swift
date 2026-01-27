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


public struct OpenAPIAnyOfType : OpenAPISchemaType, PointerNavigable {
    public var nullable: Bool?
    
    public var readOnly: Bool?
    
    public var writeOnly: Bool?
    
    public var xml: OpenAPIXMLObject?
    
    public var externalDocs: OpenAPIExternalDocumentation?
    
    public var example: OpenAPIExample?
    
    public var deprecated: Bool?
    
    public var extensions: OpenAPIExtension?
    
   
    
    public var ref: OpenAPISchemaReference? { nil}
    public static let DISCRIMINATOR_KEY = "discriminator"
    public static let TYPE_KEY = "anyOf"
   
    public init(types :[OpenAPISchema]) {
        self.items = types
        self.type = "anyOf"
    }
    
  
    public init(load map: StringDictionary,_ diagnostics: inout [Diagnostic]) throws {
        self.type = map.readIfPresent(Self.TYPE_KEY, String.self)
        

        self.discriminator = try map.readIfPresent(Self.DISCRIMINATOR_KEY, objectType: OpenAPIDiscriminator.self)
        
        self.items = try map.mapListIfPresent(objectType: OpenAPISchema.self )
    }
    
    public func validate() throws {
        
    }
    public func element(for segmentName: String) throws -> NavigationResult {
        if let index = Int(segmentName) {
            return .navigable(self.items?[index])
        }
        if segmentName ==  OpenAPISchemaReference.REF_KEY {
            return .reference(ref?.reference)
        }
        throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIAnyOfType",segmentName)
    }
    public let type : String?
    public var items: [OpenAPISchema]?
    public var discriminator: OpenAPIDiscriminator?
    
}
