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


public struct OpenAPIObjectType : OpenAPISchemaType,ThrowingHashMapInitiable, PointerNavigable{
    public var discriminator: OpenAPIDiscriminator?
    
    public var nullable: Bool?
    
    public var readOnly: Bool?
    
    public var writeOnly: Bool?
    
    public var xml: OpenAPIXMLObject?
    
    public var externalDocs: OpenAPIExternalDocumentation?
    
    public var example: OpenAPIExample?
    
    public var deprecated: Bool?
    
    public var extensions: OpenAPIExtension?
    
   
    
    public func element(for segmentName: String) throws -> NavigationResult {
        switch segmentName {
        case Self.DEPENDENT_REQUIRED_KEY : return .value(JSONValue(self.dependentRequired))
        case Self.MIN_PROPERTIES_KEY : return .value(JSONValue(self.minProperties))
        case Self.MAX_PROPERTIES_KEY : return .value(JSONValue(self.maxProperties))
        case Self .TYPE_KEY:  return .value(JSONValue(self.type))
        case Self.UNEVALUATEDPROPERTIES_KEY : return .value(JSONValue(self.unevaluatedProperties))
        case Self .PROPERTIES_KEY: return try  self.properties.element(for: segmentName)
        case Self .REQUIRED_KEY: return  .value(JSONValue(self.required))
        default:
            if let prop = self.properties[key: segmentName] {
                return .navigable( prop)
            }
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPISpecificationType", segmentName)
            
        }
    }
    public static let DEPENDENT_REQUIRED_KEY = "dependentRequired"
    public static let TYPE_KEY = "type"
    public static let PROPERTIES_KEY = "properties"
    public static let MAX_PROPERTIES_KEY = "maxProperties"
    public static let MIN_PROPERTIES_KEY = "minProperties"
    public static let UNEVALUATEDPROPERTIES_KEY = "unevaluatedProperties"
    public static let REQUIRED_KEY = "required"
    public init(load map: StringDictionary,_ diagnostics: inout [Diagnostic]) throws {
        self.type = map.readIfPresent(Self.TYPE_KEY, valueType: String.self)
        self.properties = try map.mapListIfPresent(Self.PROPERTIES_KEY, objectType: OpenAPINamedSchema.self)
        
        self.required = map.readListIfPresent(Self.REQUIRED_KEY, valueType: String.self) ?? []
        self.minProperties = map.readIfPresent(Self.MIN_PROPERTIES_KEY, valueType: Int.self)
        self.maxProperties = map.readIfPresent(Self.MAX_PROPERTIES_KEY, valueType:Int.self)
        self.dependentRequired = map.readIfPresent(Self.DEPENDENT_REQUIRED_KEY, valueType: String.self)
    }
    
    
    public let type : String?
    public var dependentRequired : String?
    public var maxProperties : Int?
    public var minProperties : Int?
    public var properties : [OpenAPINamedSchema] = []
    public var required : [String] = []
    public var unevaluatedProperties : Bool = false
  
    public var ref: OpenAPISchemaReference? { nil}
}
