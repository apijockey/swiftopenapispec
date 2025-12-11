//
//  File.swift
//  
//
//  Created by Patric Dubois on 27.03.24.
//

import Foundation

public struct OpenAPIComponent : KeyedElement, ThrowingHashMapInitiable {
  
    
    public static let ROUTE_INDEX = 0
    public static let COMPONENT_NAME_INDEX = 0
    public static let COMPONENTTYPE_INDEX = 2
    public  static let COMPONENTELEMENT_INDEX = 3
    public  enum Errors : LocalizedError {
        case unsupportedComponentlist, unrecognizedComponent
    }
    public init(_ map: StringDictionary) throws {
        
        if let map = map[Self.CALLBACKS_KEY] as? StringDictionary{
            self.callbacks = try KeyedElementList<OpenAPICallBack>.map(map)
        }
        if let map = map[Self.EXAMPLES_KEY] as? StringDictionary{
            self.examples = try KeyedElementList<OpenAPIExample>.map(map)
        }
        extensions = try OpenAPIExtension.extensionElements(map)
        
        if let map = map[Self.HEADERS_KEY] as? StringDictionary{
            self.examples = try KeyedElementList<OpenAPIExample>.map(map)
        }
        
        if let headerMap = map[Self.HEADERS_KEY] as? StringDictionary{
            self.headers = try KeyedElementList<OpenAPIHeader>.map(headerMap)
        }
        if let map = map[Self.LINKS_KEY] as? StringDictionary{
            self.links = try KeyedElementList<OpenAPILink>.map(map)
        }
        if let map = map[Self.MEDIATYPES_KEY] as? StringDictionary{
            self.mediaTypes = try KeyedElementList<OpenAPIMediaType>.map(map)
        }
        if let map = map[Self.PATHSITEMS_KEY] as? StringDictionary{
            self.pathItems = try KeyedElementList<OpenAPIPath>.map(map)
        }
        
      
        if let paramsMap = map[Self.PARAMETERS_KEY] as? [StringDictionary]{
            parameters = try KeyedElementList<OpenAPIParameter>.map(list:paramsMap,yamlKeyName: "name")
        }
        if let map = map[Self.REQUEST_BODIES_KEY] as? StringDictionary{
            self.requestBodies = try KeyedElementList<NamedComponent<OpenAPIRequestBody>>.map(map)
        }
        if let responsesMap = map[Self.RESPONSES_KEY] as? StringDictionary{
            responses = try KeyedElementList<OpenAPIResponse>.map(responsesMap)
        }
        if let schemasMap = map[Self.SCHEMAS_KEY] as? StringDictionary{
            schemas = try KeyedElementList<NamedComponent<OpenAPISchema>>.map(schemasMap)
        }
        if let securitySchemaMap = map[Self.SECURITY_SCHEMES_KEY] as? StringDictionary{
            self.securitySchemas = try KeyedElementList<OpenAPISecurityScheme>.map(securitySchemaMap)
        }
        
    }
    public func resolveSchemaComponent(components : [String]) throws ->  OpenAPISchema?{
        if components.count < 4 {
            throw Self.Errors.unsupportedComponentlist
        }
        //let _  = components[Self.ROUTE_INDEX]
        //let _  = components[Self.COMPONENT_NAME_INDEX ]
        let componenttype = components[Self.COMPONENTTYPE_INDEX ]
        let componentname = components[Self.COMPONENTELEMENT_INDEX ]
        switch componenttype  {
        case Self.SCHEMAS_KEY : return schemas?.first { schema in
            schema.key == componentname
        }?.namedComponentType
        default:
            throw Self.Errors.unrecognizedComponent
        }       
    }
    public  static let CALLBACKS_KEY = "callbacks"
    public static let EXAMPLES_KEY = "examples"
    public static let HEADERS_KEY = "headers"
    public static let LINKS_KEY = "links"
    public  static let MEDIATYPES_KEY = "mediaTypes"
    public  static let PATHSITEMS_KEY = "pathItems"
    public static let PARAMETERS_KEY = "parameters"
    public static let REQUEST_BODIES_KEY = "requestBodies"
    public static let RESPONSES_KEY = "responses"
    public static let SCHEMAS_KEY = "schemas"
    public static let SECURITY_SCHEMES_KEY = "securitySchemes"
    
    //TODO: Callback
    public var extensions : [OpenAPIExtension]?
    public var examples : [OpenAPIExample]?
    public var callbacks : [OpenAPICallBack]?
    public var headers : [OpenAPIHeader]?
    public var key: String?
    public var parameters : [OpenAPIParameter]?
    public var pathItems : [OpenAPIPath]?
    public var mediaTypes : [OpenAPIMediaType]?
    public var links: [OpenAPILink]?
    public var requestBodies : [NamedComponent<OpenAPIRequestBody>]?
    public var responses : [OpenAPIResponse]?
    public var securitySchemas : [OpenAPISecurityScheme]?
    public var schemas : [NamedComponent<OpenAPISchema>]?
    public var userInfos =  [OpenAPIObject.UserInfo]()
    
    
    
    //https://swagger.io/docs/specification/v3_0/components/
}


