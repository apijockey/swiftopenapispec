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

public struct OpenAPILink : KeyedElement , PointerNavigable,OpenAPISchemaReferenceable {
    public static let OPERATIION_REF_KEY = "operationRef"
    public static let OPERATIION_ID_KEY = "operationId"
    public static let PARAMETERS_KEY = "parameters"
    public static let REQUEST_BODY_KEY = "requestBody"
    public static let DESCRIPTION_KEY = "description"
    public static let SERVER_KEY = "server"
    
    public static func initialize(_ map: StringDictionary) throws ->  InitializationResult<Self> {
           let element = try Self(load: map)
           return InitializationResult(value: element, diagnostics: [])
       }
    public init(load map: [String : Any]) throws {
        if let ref  =  try OpenAPISchemaReference.initReference(from: (map)) {
            self.ref = ref
            return
        }
        description = map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
        extensions = try OpenAPIExtension.extensionElements(map)
        operationRef = map.readIfPresent(Self.OPERATIION_REF_KEY, String.self)
        operationId = map.readIfPresent(Self.OPERATIION_ID_KEY, String.self)
        server = try map.mapIfPresent(Self.SERVER_KEY, OpenAPIServer.self)
        requestBody = map.readIfPresent(Self.REQUEST_BODY_KEY, String.self)
        parameters = map.readIfPresent(Self.PARAMETERS_KEY, [String:String].self) ?? [:]
      
    }
    
    public func element(for segmentName: String) throws -> Any? {
       switch segmentName {
           case Self.OPERATIION_REF_KEY : return operationRef
           case Self.OPERATIION_ID_KEY :return operationId
           case Self.PARAMETERS_KEY :return parameters
           case Self.REQUEST_BODY_KEY :return requestBody
           case Self.DESCRIPTION_KEY :return description
           case Self.SERVER_KEY :return server
       case OpenAPISchemaReference.REF_KEY: return ref
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

