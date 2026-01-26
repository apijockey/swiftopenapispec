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
                return try callbacks.element(for: segmentName)
            }
            else {
                throw OpenAPISpecification.Errors.unsupportedSegment(segmentName, "OpenAPIComponent")
            }
        case Self.EXAMPLES_KEY:
            if let examples =  examples {
                return try examples.element(for: segmentName)
            }
            else {
                throw OpenAPISpecification.Errors.unsupportedSegment(segmentName, "OpenAPIComponent")
            }
        case Self.HEADERS_KEY:
            if let headers =  headers {
                return try headers.element(for: segmentName)
            }
            else {
                throw OpenAPISpecification.Errors.unsupportedSegment(segmentName, "OpenAPIComponent")
            }
        case Self.LINKS_KEY:
            if let links =  links {
                return try links.element(for: segmentName)
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
                return try pathItems.element(for: segmentName)
            }
            else {
                throw OpenAPISpecification.Errors.unsupportedSegment(segmentName, "OpenAPIComponent")
            }
        case Self.PARAMETERS_KEY:
            if let parameters =  parameters {
                return try parameters.element(for: segmentName)
            }
            else {
                throw OpenAPISpecification.Errors.unsupportedSegment(segmentName, "OpenAPIComponent")
            }
        case Self.REQUEST_BODIES_KEY:
            if let requestBodies =  requestBodies {
                return try requestBodies.element(for: segmentName)
            }
            else {
                throw OpenAPISpecification.Errors.unsupportedSegment(segmentName, "OpenAPIComponent")
            }
        case Self.RESPONSES_KEY:
            if let responses =  responses {
                return try responses.element(for: segmentName)
            }
            else {
                throw OpenAPISpecification.Errors.unsupportedSegment(segmentName, "OpenAPIComponent")
            }
        case Self.SCHEMAS_KEY:
            if let schemas =  schemas {
                return try schemas.element(for: segmentName)
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
    public static func initialize(_ map: StringDictionary) throws ->  InitializationResult<Self> {
        let element = try Self(load: map)
        return InitializationResult(value: element, diagnostics: [])

    }
    public init(load map: StringDictionary) throws {
        
        if let map = map[Self.CALLBACKS_KEY] as? StringDictionary{
            self.callbacks = try KeyedElementList<OpenAPICallBack>.map(map).value
        }
        if let map = map[Self.ENCODINGS_KEY] as? StringDictionary{
            self.mediaTypes = try KeyedElementList<OpenAPIMediaType>.map(map).value
        }
        if let map = map[Self.EXAMPLES_KEY] as? StringDictionary{
            self.examples = try KeyedElementList<OpenAPIExample>.map(map).value
        }
        extensions = try OpenAPIExtension.extensionElements(map)
        
        if let map = map[Self.HEADERS_KEY] as? StringDictionary{
            self.headers = try KeyedElementList<OpenAPIHeader>.map(map).value
        }
        
       
        if let map = map[Self.LINKS_KEY] as? StringDictionary{
            self.links = try KeyedElementList<OpenAPILink>.map(map).value
        }
        if let map = map[Self.MEDIATYPES_KEY] as? StringDictionary{
            self.mediaTypes = try KeyedElementList<OpenAPIMediaType>.map(map).value
        }
        if let map = map[Self.PATHSITEMS_KEY] as? StringDictionary{
            self.pathItems = try KeyedElementList<OpenAPIPathItem>.map(map).value
        }
        
      
        if let paramsMap = map[Self.PARAMETERS_KEY] as? StringDictionary {
            parameters = try KeyedElementList<OpenAPIParameter>.map(paramsMap).value
        }
        if let map = map[Self.REQUEST_BODIES_KEY] as? StringDictionary{
            self.requestBodies = try KeyedElementList<OpenAPIRequestBody>.map(map).value
        }
        if let responsesMap = map[Self.RESPONSES_KEY] as? StringDictionary{
            responses = try KeyedElementList<OpenAPIResponse>.map(responsesMap).value
        }
        if let schemasMap = map[Self.SCHEMAS_KEY] as? StringDictionary{
            schemas = try KeyedElementList<OpenAPINamedSchema>.map(schemasMap).value
        }
        if let securitySchemaMap = map[Self.SECURITY_SCHEMES_KEY] as? StringDictionary{
            self.securitySchemas = try KeyedElementList<OpenAPISecurityScheme>.map(securitySchemaMap).value
        }
        
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
    public var schemas : [OpenAPINamedSchema]?
   
    public var ref : OpenAPISchemaReference? { nil}
    
    
    //https://swagger.io/docs/specification/v3_0/components/
}


