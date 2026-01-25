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


public struct OpenAPIAllOfType : OpenAPISchemaType, ThrowingHashMapInitiable, PointerNavigable, OpenAPISchemaReferenceable {
    public var nullable: Bool?
    
    public var readOnly: Bool?
    
    public var writeOnly: Bool?
    
    public var xml: OpenAPIXMLObject?
    
    public var externalDocs: OpenAPIExternalDocumentation?
    
    public var example: OpenAPIExample?
    
    public var deprecated: Bool?
    
    public var extensions: OpenAPIExtension?
    
  
    
    public func element(for segmentName: String) throws -> Any? {
        if let index = Int(segmentName) {
            //return self.items?[index]
        }
        if segmentName ==  OpenAPISchemaReference.REF_KEY {
            return ref
        }
        throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIOneOfType",segmentName)
    }
    
    public var ref: OpenAPISchemaReference?
   
    public static let TYPE_KEY = "allOf"
    public static let DISCRIMINATOR_KEY = "discriminator"
    public static func initialize(_ map: StringDictionary) throws ->  InitializationResult<Self> {
           let element = try Self(load: map)
           return InitializationResult(value: element, diagnostics: [])
       }

    public init(load map: [String : Any]) throws {
        self.type = map[Self.TYPE_KEY] as? String
        guard let list = (map["allOf"] as? [Any]) else {
            return
        }
        self.items = try HashmapInitializableList<OpenAPISchema>.map( list).value
        if let discriminatorMap = map[Self.DISCRIMINATOR_KEY] as? [String:Any] {
            self.discriminator = try OpenAPIDiscriminator(load: discriminatorMap)
        }
    }
    
    public func validate() throws {
        
    }

    public let type : String?
    public var items: [OpenAPISchema]?
    public var discriminator: OpenAPIDiscriminator?
  
}
