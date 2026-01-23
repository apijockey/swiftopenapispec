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
    
    public func element(for segmentName : String) throws -> Any? {
        switch segmentName {
            case Self.CALLBACKS_KEY:
            return callbacks
        case Self.EXAMPLES_KEY:
            return examples
        case Self.HEADERS_KEY:
            return headers
        case Self.LINKS_KEY:
            return links
        case Self.MEDIATYPES_KEY:
            return mediaTypes
        case Self.PATHSITEMS_KEY:
            return pathItems
        case Self.PARAMETERS_KEY:
            return parameters
        case Self.REQUEST_BODIES_KEY:
            return requestBodies
        case Self.RESPONSES_KEY:
            return responses
        case Self.SCHEMAS_KEY:
            return schemas
        case Self.SECURITY_SCHEMES_KEY:
            return self.securitySchemas
        
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


