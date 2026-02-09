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
    
    
   
    
    public func element(for segmentName: String) throws -> NavigationResult {
        switch segmentName {
        case Self.DEPENDENT_REQUIRED_KEY : return .value(JSONValue(string: self.dependentRequired))
        case Self.MIN_PROPERTIES_KEY : return .value(JSONValue(int: self.minProperties))
        case Self.MAX_PROPERTIES_KEY : return .value(JSONValue(int: self.maxProperties))
        
        case Self .TYPE_KEY:  return .value(JSONValue(string: self.type))
        case Self.UNEVALUATEDPROPERTIES_KEY : return .value(JSONValue(bool: self.unevaluatedProperties))
        case Self .PROPERTIES_KEY:
            return .navigableCollection(properties)
        case Self .PATTERNPROPERTIES_KEY:
            return .navigableCollection(patternProperties)
        case Self .REQUIRED_KEY:
            let value = try JSONValue(self.required)
            return  .value(value)
        default:
            if let prop = self.properties.first(where: { element in
                element.key == segmentName
            }) {
                return .navigable( prop)
            }
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPISpecificationType", segmentName)
            
        }
    }
    public static let DEPENDENT_REQUIRED_KEY = "dependentRequired"
    public static let TYPE_KEY = "type"
    public static let PROPERTIES_KEY = "properties"
    public static let PATTERNPROPERTIES_KEY = "patternProperties"
    public static let MAX_PROPERTIES_KEY = "maxProperties"
    public static let MIN_PROPERTIES_KEY = "minProperties"
    public static let ADDITIONAL_PROPERTIES_KEY = "additionalProperties"
    public static let UNEVALUATEDPROPERTIES_KEY = "unevaluatedProperties"
    public static let REQUIRED_KEY = "required"
    public init(load map: StringDictionary, diagnostics: inout [Diagnostic],pointer : String) throws {
        self.type = map.readIfPresent(Self.TYPE_KEY, valueType: String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.TYPE_KEY))
        self.properties = try map.mapListIfPresent(Self.PROPERTIES_KEY, objectType: OpenAPISchema.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.PROPERTIES_KEY))
        self.patternProperties = try map.mapListIfPresent(Self.PATTERNPROPERTIES_KEY, objectType: OpenAPISchema.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.PATTERNPROPERTIES_KEY))
        self.required = map.readListIfPresent(Self.REQUIRED_KEY, valueType: String.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.REQUIRED_KEY)) ?? []
        self.minProperties = map.readIfPresent(Self.MIN_PROPERTIES_KEY, valueType: Int.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.MIN_PROPERTIES_KEY))
        self.maxProperties = map.readIfPresent(Self.MAX_PROPERTIES_KEY, valueType:Int.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.MAX_PROPERTIES_KEY))
        self.dependentRequired = map.readIfPresent(Self.DEPENDENT_REQUIRED_KEY, valueType: String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.DEPENDENT_REQUIRED_KEY))
        if let additionalPropertiesBool = map.readIfPresent(Self.ADDITIONAL_PROPERTIES_KEY, valueType: Bool.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.ADDITIONAL_PROPERTIES_KEY)) {
            self.additionalPropertiesValid = additionalPropertiesBool
        }
        if let additionalPropertiesObject = try? map.readIfPresent(Self.ADDITIONAL_PROPERTIES_KEY, objectType: OpenAPIType.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.ADDITIONAL_PROPERTIES_KEY)) {
            self.additionalPropertiesObject = additionalPropertiesObject
        }
    }
    
    
    public let type : String?
    public var dependentRequired : String?
    public var maxProperties : Int?
    public var minProperties : Int?
    public var properties = [OpenAPISchema]()
    public var patternProperties = [OpenAPISchema]()
    public var additionalPropertiesValid : Bool?
    public var additionalPropertiesObject : OpenAPIType?
    public var required : [String] = []
    public var unevaluatedProperties : Bool = false
    public var discriminator: OpenAPIDiscriminator?
    public var nullable: Bool?
    public var readOnly: Bool?
    public var writeOnly: Bool?
    public var xml: OpenAPIXMLObject?
    public var externalDocs: OpenAPIExternalDocumentation?
    public var example: OpenAPIExample?
    public var deprecated: Bool?
    public var extensions: OpenAPIExtension?
  
    
}
