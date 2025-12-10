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
    public init(_ map: [String : Any]) throws {
        if let schemasMap = map[Self.SCHEMAS_KEY] as? [String : Any]{
            schemas = try KeyedElementList<NamedComponent<OpenAPISchema>>.map(schemasMap)
        }
        if let paramsMap = map[Self.PARAMETERS_KEY] as? [String : Any]{
            parameters = try KeyedElementList<NamedComponent<OpenAPIParameter>>.map(paramsMap)
        }
        if let responsesMap = map[Self.RESPONSES_KEY] as? [String : Any]{
            responses = try KeyedElementList<OpenAPIResponse>.map(responsesMap)
        }
        if let securitySchemaMap = map[Self.SECURITY_SCHEMES_KEY] as? [String : Any]{
            self.securitySchemas = try KeyedElementList<OpenAPISecurityScheme>.map(securitySchemaMap)
        }
        if let headerMap = map[Self.HEADERS_KEY] as? [String: Any]{
            self.headers = try KeyedElementList<OpenAPIHeader>.map(headerMap)
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
        }?.namedComponentType
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
    public var key: String?
    public var userInfos =  [OpenAPIObject.UserInfo]()
    //https://swagger.io/docs/specification/v3_0/components/
}

public extension Array where Element == OpenAPIComponent {
    subscript(component: String) -> OpenAPIComponent? {
        return self.first (where:{ c in
            c.key == component
        })
    }

    
}
