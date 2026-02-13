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
//

import Foundation

/// A structure representing a single operation in an OpenAPI specification.
///
/// An `OpenAPIOperation` describes a single API operation on a path, including its parameters,
/// request body, responses, security requirements, and other operation-specific information.
///
/// Operations are the core building blocks of an OpenAPI specification, defining what actions
/// can be performed on API endpoints and how they should behave.
public struct OpenAPIOperation : KeyedElement, PointerNavigable {
    public var key: String?
    /// Creates an `OpenAPIOperation` instance from a dictionary representation.
    ///
    /// - Parameters:
    ///   - map: A dictionary containing the OpenAPI operation data
    ///   - diagnostics: An array to collect any diagnostic messages during parsing
    ///   - pointer: A JSON pointer indicating the location in the source document
    /// - Throws: An error if the input data is invalid or required fields are missing
    public init(load map: StringDictionary,diagnostics: inout [Diagnostic],pointer : String) throws {
        self.tags = map.readListIfPresent(Self.TAGS_KEY, valueType: String.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.TAGS_KEY))  ?? []
        self.summary = map.readIfPresent(Self.SUMMARY_KEY, valueType:  String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.SUMMARY_KEY))
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY,valueType:   String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.DESCRIPTION_KEY))
        self.externalDocs = try map.readIfPresent(Self.EXTERNAL_DOCS_KEY, objectType:  OpenAPIExternalDocumentation.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.EXTERNAL_DOCS_KEY))
        self.operationId = map.readIfPresent(Self.OP_ID_KEY, valueType:  String.self, diagnostics : &diagnostics, pointer:JSONPointer.join(pointer, Self.OP_ID_KEY))
        self.parameters = try map.mapListIfPresent(Self.PARAMETERS_KEY, objectType: OpenAPIParameter.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.PARAMETERS_KEY))
        self.requestBody = try map.readIfPresent(Self.REQUEST_BODIES_KEY, objectType: OpenAPIRequestBody.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.REQUEST_BODIES_KEY))
        self.responses = try map.mapListIfPresent(Self.RESPONSES_KEY, objectType: OpenAPIResponse.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.RESPONSES_KEY))
        self.callbacks =  try map.mapListIfPresent(Self.CALLBACKS_KEY, objectType: OpenAPICallBack.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.CALLBACKS_KEY))
        self.deprecated = map.readIfPresent(Self.DEPRECATED_KEY, valueType: Bool.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.DEPRECATED_KEY))
        self.securityObjects = try map.mapListIfPresent(Self.SECURITY_KEY, objectType: OpenAPISecuritySchemeReference.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.SECURITY_KEY))
        self.servers =  try map.mapListIfPresent(OpenAPISpecification.SERVERS_KEY, objectType: OpenAPIServer.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, OpenAPISpecification.SERVERS_KEY))
        extensions = try OpenAPIExtension.extensionElements(map, &diagnostics,pointer: JSONPointer.join(pointer, "extensions"))
       
       
        
    }
   
    /// Navigates to a specific element within the OpenAPI operation structure.
    ///
    /// - Parameter segmentName: The name of the element to navigate to
    /// - Returns: A `NavigationResult` containing either the requested value or a navigable element
    /// - Throws: An error if the requested element does not exist
    public func element(for segmentName: String) throws -> NavigationResult {
        switch segmentName {
            
        case Self.DEPRECATED_KEY:
            let value = try JSONValue(deprecated)
            return .value(value)
        case Self.DESCRIPTION_KEY: return .value(JSONValue(description))
        case Self.EXTERNAL_DOCS_KEY: return .navigable(externalDocs)
        case Self.OP_ID_KEY: return .value(JSONValue(operationId))
        case Self.PARAMETERS_KEY:
            return   .navigableCollection(parameters)
            
        case Self.REQUEST_BODIES_KEY: return .navigable(requestBody)
        case Self.RESPONSES_KEY: return .navigableCollection(responses)
        case Self.SUMMARY_KEY: return  .value(JSONValue(summary))
        case Self.SECURITY_KEY:
            
            return try securityObjects.element(for: segmentName)
            
        case Self.TAGS_KEY:
            let value = try JSONValue(tags)
            return .value(value)
           
        default:
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIOperation", segmentName)
        }
    }
    public static let DEPRECATED_KEY = "deprecated"
    public static let CALLBACKS_KEY = "callbacks"
    public static let DESCRIPTION_KEY = "description"
    public static let EXTERNAL_DOCS_KEY = "externalDocs"
    public static let OP_ID_KEY = "operationId"
    public static let PARAMETERS_KEY = "parameters"
    public static let RESPONSES_KEY = "responses"
    //https://swagger.io/docs/specification/paths-and-operations/
    public static let SUMMARY_KEY = "summary"
    public static let TAGS_KEY = "tags"
    
    public static let REQUEST_BODIES_KEY = "requestBody"
    public static let SECURITY_KEY = "security"
    
    public var deprecated : Bool? = false
    public var operationId : String? = nil
    public var summary : String? = nil
    public var requestBody : OpenAPIRequestBody? = nil
    public var description : String? = nil
    public var tags : [String] = []
   
    public var callbacks : [OpenAPICallBack] = []
    public var responses : [OpenAPIResponse] = []
    public var parameters : [OpenAPIParameter] = []
    public var servers : [OpenAPIServer] = [OpenAPIServer(url: "/")]
    //Lists the required security schemes to execute this operation. The name used for each property MUST correspond to a security scheme declared in the Security Schemes under the Components Object.
    public var securityObjects : [OpenAPISecuritySchemeReference] = []
    public var extensions : [OpenAPIExtension]?
    public var externalDocs : OpenAPIExternalDocumentation? = nil
  
   
  
    /// returns an OpenAPIResponse for the given HTTP Status  if declared on the operation or nil.
    public func response(httpstatus  status : String) -> OpenAPIResponse? {
        guard responses.count > 0  else { return nil }
        return responses[key: status]
    }
    
    
    
}


extension Array where Element == OpenAPIOperation {
    public subscript(operationID  id : String) -> OpenAPIOperation? {
        return self.first { operation in
            operation.operationId == id
        }
    }
}
