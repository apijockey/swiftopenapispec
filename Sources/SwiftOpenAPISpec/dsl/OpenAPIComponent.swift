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

//  Created by Patric Dubois on 27.03.24.
//

import Foundation

public struct OpenAPIComponent : KeyedElement,PointerNavigable  {
   
    
    public  static let CALLBACKS_KEY = "callbacks"
    public static let EXAMPLES_KEY = "examples"
    public static let HEADERS_KEY = "headers"
    public static let LINKS_KEY = "links"
    public  static let MEDIATYPES_KEY = "mediaTypes"
    public static let PATHSITEMS_KEY = "pathItems"
    public static let PARAMETERS_KEY = "parameters"
    public static let ENCODINGS_KEY = "encodings"
    public static let REQUEST_BODIES_KEY = "requestBodies"
    public static let RESPONSES_KEY = "responses"
    public static let SCHEMAS_KEY = "schemas"
    public static let SECURITY_SCHEMES_KEY = "securitySchemes"
    
    public func element(for segmentName : String) throws -> NavigationResult {
        switch segmentName {
            case Self.CALLBACKS_KEY:
            
            if let callbacks = callbacks {
                return .navigableCollection(callbacks)
            }
            else {
                throw OpenAPISpecification.Errors.unsupportedSegment(segmentName, "OpenAPIComponent")
            }
        case Self.EXAMPLES_KEY:
            if let examples =  examples {
                return .navigableCollection(examples)
            }
            else {
                throw OpenAPISpecification.Errors.unsupportedSegment(segmentName, "OpenAPIComponent")
            }
        case Self.HEADERS_KEY:
            if let headers =  headers {
                return .navigableCollection(headers)
            }
            else {
                throw OpenAPISpecification.Errors.unsupportedSegment(segmentName, "OpenAPIComponent")
            }
        case Self.LINKS_KEY:
            if let links =  links {
                return  .navigableCollection(links)
            }
            else {
                throw OpenAPISpecification.Errors.unsupportedSegment(segmentName, "OpenAPIComponent")
            }
        case Self.MEDIATYPES_KEY:
            if let mediaTypes =  mediaTypes {
                return try mediaTypes.element(for: segmentName)
            }
            else {
                throw OpenAPISpecification.Errors.unsupportedSegment(segmentName, "OpenAPIComponent")
            }
        case Self.PATHSITEMS_KEY:
            if let pathItems =  pathItems {
                return .navigableCollection(pathItems)
            }
            else {
                throw OpenAPISpecification.Errors.unsupportedSegment(segmentName, "OpenAPIComponent")
            }
        case Self.PARAMETERS_KEY:
            if let parameters =  parameters {
                return try .value(JSONValue(parameters.first(where: { $0.key == segmentName })))
            }
            else {
                throw OpenAPISpecification.Errors.unsupportedSegment(segmentName, "OpenAPIComponent")
            }
        case Self.REQUEST_BODIES_KEY:
            if let requestBodies =  requestBodies {
                return .navigableCollection(requestBodies)
            }
            else {
                throw OpenAPISpecification.Errors.unsupportedSegment(segmentName, "OpenAPIComponent")
            }
        case Self.RESPONSES_KEY:
            if let responses =  responses {
                return  .navigableCollection(responses)
            }
            else {
                throw OpenAPISpecification.Errors.unsupportedSegment(segmentName, "OpenAPIComponent")
            }
        case Self.SCHEMAS_KEY:
            if let schemas =  schemas {
                // Expose the whole collection for searching; resolver will pick by key.
                return .navigableCollection(schemas)
            }
            else {
                throw OpenAPISpecification.Errors.unsupportedSegment(segmentName, "OpenAPIComponent")
            }
        case Self.SECURITY_SCHEMES_KEY:
            if let securitySchemas =   securitySchemas {
                return try securitySchemas.element(for: segmentName)
            }
            else {
                throw OpenAPISpecification.Errors.unsupportedSegment(segmentName, "OpenAPIComponent")
            }
        
        default :
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIComponent", segmentName)
        }
    }
   
    public  enum Errors : LocalizedError {
        case unsupportedComponentlist, unrecognizedComponent
    }
   
   
    
public init(load map: StringDictionary, _ diagnostics: inout [Diagnostic]) throws {
        
            self.callbacks = try map.mapListIfPresent(Self.CALLBACKS_KEY, objectType: OpenAPICallBack.self)
            self.mediaTypes = try map.mapListIfPresent(Self.ENCODINGS_KEY, objectType: OpenAPIMediaType.self)
            self.examples =  try map.mapListIfPresent(Self.EXAMPLES_KEY, objectType: OpenAPIExample.self)
            extensions = try OpenAPIExtension.extensionElements(map, &diagnostics)
            self.headers =  try map.mapListIfPresent(Self.HEADERS_KEY, objectType: OpenAPIHeader.self)
            self.links =   try map.mapListIfPresent(Self.LINKS_KEY, objectType: OpenAPILink.self)
            self.mediaTypes =  try map.mapListIfPresent(Self.MEDIATYPES_KEY, objectType: OpenAPIMediaType.self)
            self.pathItems =   try map.mapListIfPresent(Self.PATHSITEMS_KEY, objectType: OpenAPIPathItem.self)
            parameters =   try map.mapListIfPresent(Self.PARAMETERS_KEY, objectType: OpenAPIParameter.self)
            self.requestBodies =   try map.mapListIfPresent(Self.REQUEST_BODIES_KEY, objectType: OpenAPIRequestBody.self)
            responses =  try map.mapListIfPresent(Self.RESPONSES_KEY, objectType: OpenAPIResponse.self)
            schemas =   try map.mapListIfPresent(Self.SCHEMAS_KEY, objectType: OpenAPISchema.self)
            self.securitySchemas =   try map.mapListIfPresent(Self.SECURITY_SCHEMES_KEY, objectType:OpenAPISecurityScheme.self)
        
    }
   
    
    
    public var extensions : [OpenAPIExtension]?
    public var examples : [OpenAPIExample]?
    public var callbacks : [OpenAPICallBack]?
    public var headers : [OpenAPIHeader]?
    public var key: String?
    public var links: [OpenAPILink]?
    public var parameters : [OpenAPIParameter]?
    public var pathItems : [OpenAPIPathItem]?
    public var mediaTypes : [OpenAPIMediaType]?
  
    public var requestBodies : [OpenAPIRequestBody]?
    public var responses : [OpenAPIResponse]?
    public var securitySchemas : [OpenAPISecurityScheme]?
    public var schemas : [OpenAPISchema]?
   
    public var ref : OpenAPISchemaReference? { nil}
    
    
    //https://swagger.io/docs/specification/v3_0/components/
}


