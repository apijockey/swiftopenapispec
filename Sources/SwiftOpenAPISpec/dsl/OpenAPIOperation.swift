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

public struct OpenAPIOperation : KeyedElement, PointerNavigable {
    public var key: String?
    public init(load map: StringDictionary,_ diagnostics: inout [Diagnostic]) throws {
        self.tags = map.readListIfPresent(Self.TAGS_KEY, valueType: String.self)  ?? []
        self.summary = map.readIfPresent(Self.SUMMARY_KEY, valueType:  String.self)
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY,valueType:   String.self)
        self.externalDocs = try map.readIfPresent(Self.EXTERNAL_DOCS_KEY, objectType:  OpenAPIExternalDocumentation.self)
        self.operationId = map.readIfPresent(Self.OP_ID_KEY, valueType:  String.self)
        self.parameters = try map.mapListIfPresent(Self.PARAMETERS_KEY, objectType: OpenAPIParameter.self)
        self.requestBody = try map.readIfPresent(Self.REQUEST_BODIES_KEY, objectType: OpenAPIRequestBody.self)
        self.responses = try map.mapListIfPresent(Self.RESPONSES_KEY, objectType: OpenAPIResponse.self)
        self.callbacks =  try map.mapListIfPresent(Self.CALLBACKS_KEY, objectType: OpenAPICallBack.self)
        self.deprecated = map.readIfPresent(Self.DEPRECATED_KEY, valueType: Bool.self)
        self.securityObjects = try map.mapListIfPresent(Self.SECURITY_KEY, objectType: OpenAPISecuritySchemeReference.self)
        self.servers =  try map.mapListIfPresent(OpenAPISpecification.SERVERS_KEY, objectType: OpenAPIServer.self)
        extensions = try OpenAPIExtension.extensionElements(map)
       
       
        
    }
   
    public func element(for segmentName: String) throws -> NavigationResult {
        switch segmentName {
            
        case Self.DEPRECATED_KEY:  return .value(JSONValue(deprecated))
        case Self.DESCRIPTION_KEY: return .value(JSONValue(description))
        case Self.EXTERNAL_DOCS_KEY: return .navigable(externalDocs)
        case Self.OP_ID_KEY: return .value(JSONValue(operationId))
        case Self.PARAMETERS_KEY: return  try parameters.element(for: segmentName)
        case Self.REQUEST_BODIES_KEY: return .navigable(requestBody)
        case Self.RESPONSES_KEY: return try responses.element(for: segmentName)
        case Self.SUMMARY_KEY: return  .value(JSONValue(summary))
        case Self.SECURITY_KEY:
            let value =  securityObjects.element(for: segmentName)
            return .value(JSONValue(value))
        case Self.TAGS_KEY: return .value(JSONValue(tags))
        default:
            if segmentName.hasPrefix("x-"), let exts = extensions {
//                if let ext = exts.first(where: { $0.key == segmentName }) {
//                    // Gib die strukturierte oder einfache Extension zurück
//                    return ext.structuredExtension?.properties ?? ext.simpleExtensionValue
//                }
//               
                
                
            }
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
  
    public var ref: OpenAPISchemaReference? { nil}
  
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
