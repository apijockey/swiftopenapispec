//
//  File.swift
//  
//
//  Created by Patric Dubois on 27.03.24.
//

import Foundation

public struct OpenAPIComponent : ThrowingHashMapInitiable {
    public static let ROUTE_INDEX = 0
    public static let COMPONENT_NAME_INDEX = 0
    public static let COMPONENTTYPE_INDEX = 2
    public  static let COMPONENTELEMENT_INDEX = 3
    public  enum Errors : LocalizedError {
        case unsupportedComponentlist, unrecognizedComponent
    }
    public init(_ map: [AnyHashable : Any]) throws {
        if let schemasMap = map[Self.SCHEMAS_KEY] as? [AnyHashable : Any]{
            schemas = try MapListMap<NamedComponent<OpenAPISchema>>.map(schemasMap)
        }
        if let paramsMap = map[Self.PARAMETERS_KEY] as? [AnyHashable : Any]{
            parameters = try MapListMap<NamedComponent<OpenAPIParameter>>.map(paramsMap)
        }
        if let responsesMap = map[Self.RESPONSES_KEY] as? [AnyHashable : Any]{
            responses = try MapListMap<OpenAPIResponse>.map(responsesMap)
        }
        if let securitySchemaMap = map[Self.SECURITY_SCHEMES_KEY] as? [AnyHashable : Any]{
            self.securitySchemas = try MapListMap<OpenAPISecurityScheme>.map(securitySchemaMap)
        }
        if let headerMap = map[Self.HEADERS_KEY] as? [AnyHashable : Any]{
            self.headers = try MapListMap<OpenAPIHeader>.map(headerMap)
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
        case Self.SCHEMAS_KEY : return schemas.first { schema in
            schema.key == componentname
        }?.type
        default:
            throw Self.Errors.unrecognizedComponent
        }       
    }
    public static let SCHEMAS_KEY = "schemas"
    public static let PARAMETERS_KEY = "parameters"
    public static let SECURITY_SCHEMES_KEY = "securitySchemes"
    public static let REQUEST_BODIES_KEY = "requestBodies"
    public static let RESPONSES_KEY = "responses"
    public static let HEADERS_KEY = "headers"
    public static let EXAMPLES_KEY = "examples"
    public static let LINKS_KEY = "examples"
    public  static let CALLBACKS_KEY = "examples"
    public var schemas : [NamedComponent<OpenAPISchema>] = []
    public var parameters : [NamedComponent<OpenAPIParameter>] = []
    public var responses : [OpenAPIResponse] = []
    public var securitySchemas : [OpenAPISecurityScheme] = []
    public var headers : [OpenAPIHeader] = []
}
