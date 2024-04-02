//
//  File.swift
//  
//
//  Created by Patric Dubois on 27.03.24.
//

import Foundation

struct OpenAPIComponent : ThrowingHashMapInitiable {
    static let ROUTE_INDEX = 0
    static let COMPONENT_NAME_INDEX = 0
    static let COMPONENTTYPE_INDEX = 2
    static let COMPONENTELEMENT_INDEX = 3
    enum Errors : LocalizedError {
        case unsupportedComponentlist, unrecognizedComponent
    }
    init(_ map: [AnyHashable : Any]) throws {
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
    func resolveSchemaComponent(components : [String]) throws ->  OpenAPISchema?{
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
    static let SCHEMAS_KEY = "schemas"
    static let PARAMETERS_KEY = "parameters"
    static let SECURITY_SCHEMES_KEY = "securitySchemes"
    static let REQUEST_BODIES_KEY = "requestBodies"
    static let RESPONSES_KEY = "responses"
    static let HEADERS_KEY = "headers"
    static let EXAMPLES_KEY = "examples"
    static let LINKS_KEY = "examples"
    static let CALLBACKS_KEY = "examples"
    var schemas : [NamedComponent<OpenAPISchema>] = []
    var parameters : [NamedComponent<OpenAPIParameter>] = []
    var responses : [OpenAPIResponse] = []
    var securitySchemas : [OpenAPISecurityScheme] = []
    var headers : [OpenAPIHeader] = []
}
