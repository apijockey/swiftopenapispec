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


// Created by Patric Dubois on 26.03.24.

import Foundation

public struct OpenAPILink : KeyedElement , PointerNavigable {
    public static let OPERATIION_REF_KEY = "operationRef"
    public static let OPERATIION_ID_KEY = "operationId"
    public static let PARAMETERS_KEY = "parameters"
    public static let REQUEST_BODY_KEY = "requestBody"
    public static let DESCRIPTION_KEY = "description"
    public static let SERVER_KEY = "server"
    
   
    public init(load map: StringDictionary, diagnostics: inout [Diagnostic],pointer : String) throws {
        if case let .string(refKey) = map[OpenAPISchemaReference.REF_KEY]{
                    self.ref = OpenAPISchemaReference(ref: refKey)
            return
        }
        description = map.readIfPresent(Self.DESCRIPTION_KEY, valueType: String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.DESCRIPTION_KEY))
        extensions = try OpenAPIExtension.extensionElements(map, &diagnostics,pointer: JSONPointer.join(pointer, "extensions"))
        operationRef = map.readIfPresent(Self.OPERATIION_REF_KEY,valueType:  String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.OPERATIION_REF_KEY))
        operationId = map.readIfPresent(Self.OPERATIION_ID_KEY,valueType:  String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.OPERATIION_ID_KEY))
        server = try map.readIfPresent(Self.SERVER_KEY, objectType: OpenAPIServer.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.SERVER_KEY))
        requestBody = map.readIfPresent(Self.REQUEST_BODY_KEY,valueType:  String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.REQUEST_BODY_KEY))
        let parameterData = map[Self.PARAMETERS_KEY]

        if case let .object(value) = parameterData {
            for (key,value) in value {
                if case let .string(stringValue) = value {
                    parameters[key] = stringValue
                }
              
            }
        }
        var supportingElments = Set(Self.supportedKeys)
        supportingElments.formUnion((self.extensions ?? []).compactMap({ $0.key }))
        diagnostics.append(contentsOf: map.diagnoseUnsupportedElements(supportedKeys: supportingElments , pointer: pointer))
           
    }
    
    public static let supportedKeys: Set<String> = [
        OPERATIION_REF_KEY,
        OPERATIION_ID_KEY,
        PARAMETERS_KEY,
        REQUEST_BODY_KEY,
        DESCRIPTION_KEY,
        OpenAPISchemaReference.REF_KEY,
        SERVER_KEY
    ]
    public func element(for segmentName: String) throws -> NavigationResult {
       switch segmentName {
       case Self.OPERATIION_REF_KEY : return .value(JSONValue(operationRef))
       case Self.OPERATIION_ID_KEY :return .value(JSONValue(operationId))
           case Self.PARAMETERS_KEY :
           let value = try JSONValue(parameters)
           return .value(value)
           case Self.REQUEST_BODY_KEY :return .value(JSONValue(requestBody))
           case Self.DESCRIPTION_KEY :return .value(JSONValue(description))
           case Self.SERVER_KEY :return .navigable(server)
       case OpenAPISchemaReference.REF_KEY: return .reference(ref?.reference)
       default:
           throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPILink", segmentName)
        }
    }
    public var key : String? = nil
    public var ref : OpenAPISchemaReference? = nil
    public var operationRef : String? = nil
    public var operationId : String? = nil
    public var description : String? = nil
    public var server : OpenAPIServer? = nil
    public var parameters : [String:String] = [:]
    public var requestBody : String? = nil
   
    public var extensions : [OpenAPIExtension]?
 
}

