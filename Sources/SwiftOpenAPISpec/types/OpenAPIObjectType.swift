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
        case OpenAPISchema.DEPENDENT_REQUIRED_KEY : return .value(JSONValue(string: self.dependentRequired))
        case  OpenAPISchema.MIN_PROPERTIES_KEY : return .value(JSONValue(int: self.minProperties))
        case  OpenAPISchema.MAX_PROPERTIES_KEY : return .value(JSONValue(int: self.maxProperties))
        
        case  OpenAPISchema.TYPE_KEY:  return .value(JSONValue(string: self.type))
        case  OpenAPISchema.UNEVALUATEDPROPERTIES_KEY : return .value(JSONValue(bool: self.unevaluatedProperties))
        case  OpenAPISchema.PROPERTIES_KEY:
            return .navigableCollection(properties)
        case  OpenAPISchema.PATTERNPROPERTIES_KEY:
            return .navigableCollection(patternProperties)
        case  OpenAPISchema.REQUIRED_KEY:
            let value = try JSONValue(self.required)
            return  .value(value)
        case  OpenAPISchema.DEPENDENCIES_KEY:
            if let dependencies = self.dependencies {
                let value = try JSONValue(dependencies)
                return .value(value)
            } else {
                return .value(.null)
            }
        default:
            if let prop = self.properties.first(where: { element in
                element.key == segmentName
            }) {
                return .navigable( prop)
            }
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPISpecificationType", segmentName)
            
        }
    }
    
    public init(load map: StringDictionary, diagnostics: inout [Diagnostic],pointer : String) throws {
        self.type = map.readIfPresent(OpenAPISchema.TYPE_KEY, valueType: String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, OpenAPISchema.TYPE_KEY))
        self.properties = try map.mapListIfPresent(OpenAPISchema.PROPERTIES_KEY, objectType: OpenAPISchema.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, OpenAPISchema.PROPERTIES_KEY))
        self.patternProperties = try map.mapListIfPresent(OpenAPISchema.PATTERNPROPERTIES_KEY, objectType: OpenAPISchema.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, OpenAPISchema.PATTERNPROPERTIES_KEY))
        self.required = map.readListIfPresent(OpenAPISchema.REQUIRED_KEY, valueType: String.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, OpenAPISchema.REQUIRED_KEY)) ?? []
        self.minProperties = map.readIfPresent(OpenAPISchema.MIN_PROPERTIES_KEY, valueType: Int.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, OpenAPISchema.MIN_PROPERTIES_KEY))
        self.maxProperties = map.readIfPresent(OpenAPISchema.MAX_PROPERTIES_KEY, valueType:Int.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, OpenAPISchema.MAX_PROPERTIES_KEY))
        self.dependentRequired = map.readIfPresent(OpenAPISchema.DEPENDENT_REQUIRED_KEY, valueType: String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, OpenAPISchema.DEPENDENT_REQUIRED_KEY))
        
        diagnostics.append(contentsOf: map.diagnoseUnsupportedElements(supportedKeys: OpenAPISchema.supportedKeys , pointer: pointer))
        // Parse dependencies
        if let dependenciesValue = map[OpenAPISchema.DEPENDENCIES_KEY] {
            if case let .object(dependenciesObj) = dependenciesValue {
                self.dependencies = dependenciesObj
            } else {
                diagnostics.append(.init(
                    severity: .error,
                    code: .schemaViolation,
                    message: "dependencies must be an object",
                    pointer: JSONPointer.join(pointer, OpenAPISchema.DEPENDENCIES_KEY),
                    rule: "Schema.ObjectDependencies"
                ))
            }
        }
        if case .object = map[OpenAPISchema.ADDITIONAL_PROPERTIES_KEY] {
            self.additionalPropertiesObject = try map.mapListIfPresent(OpenAPISchema.ADDITIONAL_PROPERTIES_KEY, objectType: OpenAPISchema.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, OpenAPISchema.ADDITIONAL_PROPERTIES_KEY))
        }
        else if case let .boolean(boolValue) = map[OpenAPISchema.ADDITIONAL_PROPERTIES_KEY] {
            self.additionalPropertiesValid = boolValue
        }
        
    
        
      
    }
    
    
    public let type : String?
    public var dependentRequired : String?
    public var dependencies : [String: JSONValue]?
    public var maxProperties : Int?
    public var minProperties : Int?
    public var properties = [OpenAPISchema]()
    public var patternProperties = [OpenAPISchema]()
    public var additionalPropertiesValid : Bool?
    public var additionalPropertiesObject = [OpenAPISchema]()
    public var required : [String] = []
    public var unevaluatedProperties : Bool = false
   
  
    
}
