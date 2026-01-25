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
//  OpenAPIStringType.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 10.12.25.
//


public struct OpenAPIStringType :  OpenAPISchemaType,ThrowingHashMapInitiable , PointerNavigable {
    public var discriminator: OpenAPIDiscriminator?
    
    public var nullable: Bool?
    
    public var readOnly: Bool?
    
    public var writeOnly: Bool?
    
    public var xml: OpenAPIXMLObject?
    
    public var externalDocs: OpenAPIExternalDocumentation?
    
    public var example: OpenAPIExample?
    
    public var deprecated: Bool?
    
    public var extensions: OpenAPIExtension?
    
    public func element(for segmentName: String) throws -> Any? {
        switch segmentName {
            case Self.FORMAT_KEY : return format
            case Self.MAXLENGTH_KEY : return maxLength
            case Self.MINLENGTH_KEY : return minLength
            case Self.PATTERN_KEY : return pattern
            case Self.TYPE_KEY : return type
            case Self.ALLOWED_ELEMENTS_KEY : return allowedElements
            case OpenAPISchemaReference.REF_KEY : return ref
        default:
        throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIStringType", segmentName)

        }
        
    }
    
   
    
    
    public static let FORMAT_KEY : String = "format"
    public static let MAXLENGTH_KEY = "maxLength"
    public static let MINLENGTH_KEY = "minLength"
    public static let PATTERN_KEY = "pattern"
    public static let TYPE_KEY = "type"
    public static let ALLOWED_ELEMENTS_KEY = "enum"
    
    public static func initialize(_ map: StringDictionary) throws ->  InitializationResult<Self> {
           let element = try Self(load: map)
           return InitializationResult(value: element, diagnostics: [])
       }

    public init(load map: [String : Any]) throws {
        self.type = map[Self.TYPE_KEY] as? String
        if let allowedElements = map[Self.ALLOWED_ELEMENTS_KEY] as? [String] {
            self.allowedElements = Set(allowedElements)
        } else {
            self.allowedElements = nil
        }
        self.maxLength = map[Self.MAXLENGTH_KEY] as? Int
        self.minLength = map[Self.MINLENGTH_KEY] as? Int
        self.pattern = map[Self.PATTERN_KEY] as? String
        self.format = map.readIfPresent(Self.FORMAT_KEY, String.self)
    }
   
    
    public var format : String?
    public let type : String?
    public let allowedElements : Set<String>?
    public let maxLength: Int?
    public let minLength: Int?
    public let pattern: String?
   
    public var ref: OpenAPISchemaReference? { nil}
}
