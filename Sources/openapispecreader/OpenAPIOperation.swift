//
//  File.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation

struct OpenAPIOperation : KeyedElement{
    var key: String?
    init(_ map: [AnyHashable : Any]) throws {
        self.tags = map[Self.TAGS_KEY] as? [String] ?? []
        self.summary = map.readIfPresent(Self.SUMMARY_KEY, String.self)
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
        self.externalDocs = try map.mapIfPresent(Self.EXTERNAL_DOCS_KEY, OpenAPIExternalDocumentation.self)
        self.operationId = map.readIfPresent(Self.OP_ID_KEY, String.self)
        if let parameterlist = map[Self.PARAMETERS_KEY] as? [Any] {
            self.parameters = try MapList<OpenAPIParameter>.map(parameterlist)            
        }
        self.requestBody = try map.tryMapIfPresent(Self.REQUEST_BODIES_KEY, OpenAPIRequestBody.self)
        
        if let responseMap = map[Self.RESPONSES_KEY] as? [AnyHashable:Any] {
            self.responses = try MapListMap<OpenAPIResponse>.map(responseMap)
        }
         //CALLBACKS
        self.deprecated = map.readIfPresent(Self.DEPRECATED_KEY, Bool.self)
        if let securityObjectMap = map[Self.SECURITY_KEY] as?  [[String:[String]]] {
            for element in securityObjectMap {
                if let mapElement = element.first {
                    let ref = OpenAPISecuritySchemeReference(key: mapElement.key, scopes:mapElement.value)
                    securityObjects.append(ref)
                    
                }
            }
        }
        let servers =  try map.tryOptionalList(OpenAPISpec.SERVERS_KEY, root: "operations", OpenAPIServer.self)
        if servers.count > 0 {
            self.servers = servers
        }
       
       
       
        
    }
    
    static let OP_ID_KEY = "operationId"
    static let PARAMETERS_KEY = "parameters"
    static let RESPONSES_KEY = "responses"
    //https://swagger.io/docs/specification/paths-and-operations/
    static let SUMMARY_KEY = "summary"
    static let TAGS_KEY = "tags"
    static let REQUEST_BODIES_KEY = "requestBody"
    static let EXTERNAL_DOCS_KEY = "externalDocs"
    static let DEPRECATED_KEY = "deprecated"
    static let DESCRIPTION_KEY = "description"
    static let SECURITY_KEY = "security"
    var deprecated : Bool? = false
    var operationId : String? = nil
    var summary : String? = nil
    var requestBody : OpenAPIRequestBody? = nil
    var description : String? = nil
    var tags : [String] = []
    var responses : [OpenAPIResponse]? = []
    var parameters : [OpenAPIParameter]? = []
    var servers : [OpenAPIServer] = [OpenAPIServer(url: "/")]
    //Lists the required security schemes to execute this operation. The name used for each property MUST correspond to a security scheme declared in the Security Schemes under the Components Object.
    var securityObjects : [OpenAPISecuritySchemeReference] = []
    var externalDocs : OpenAPIExternalDocumentation? = nil
  
    
    
}
