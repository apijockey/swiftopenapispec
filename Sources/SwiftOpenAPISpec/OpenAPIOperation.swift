//
//  File.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation

public struct OpenAPIOperation : KeyedElement, PointerNavigable {
    public var key: String?
    public init(_ map: [String : Any]) throws {
        self.tags = map[Self.TAGS_KEY] as? [String] ?? []
        self.summary = map.readIfPresent(Self.SUMMARY_KEY, String.self)
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
        self.externalDocs = try map.mapIfPresent(Self.EXTERNAL_DOCS_KEY, OpenAPIExternalDocumentation.self)
        self.operationId = map.readIfPresent(Self.OP_ID_KEY, String.self)
        if let parameterlist = map[Self.PARAMETERS_KEY] as? [StringDictionary] {
            parameters =   try KeyedElementList<OpenAPIParameter>.map(list:parameterlist,yamlKeyName: "name")
        }
        self.requestBody = try map.MapIfPresent(Self.REQUEST_BODIES_KEY, OpenAPIRequestBody.self)
        
        if let responseMap = map[Self.RESPONSES_KEY] as? StringDictionary {
            self.responses = try KeyedElementList<OpenAPIResponse>.map(responseMap)
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
        let servers =  try map.tryOptionalList(OpenAPIObject.SERVERS_KEY, root: "operations", OpenAPIServer.self)
        if servers.count > 0 {
            self.servers = servers
        }
        extensions = try OpenAPIExtension.extensionElements(map)
       
       
        
    }
    public func element(for segmentName: String) throws -> Any? {
       switch segmentName {
       case Self .OP_ID_KEY: return operationId as String?
       case Self .PARAMETERS_KEY: return (parameters ?? []) as [OpenAPIParameter]
       case Self .RESPONSES_KEY: return (responses  ?? []) as [OpenAPIResponse] 
       case Self .SUMMARY_KEY: return summary as String?
       case Self .TAGS_KEY: return tags as [String]
       case Self .REQUEST_BODIES_KEY: return requestBody as OpenAPIRequestBody?
       case Self .EXTERNAL_DOCS_KEY: return externalDocs as OpenAPIExternalDocumentation?
       case Self .DEPRECATED_KEY: return deprecated as Bool?
       default: return nil
           
        }
    }
    public static let OP_ID_KEY = "operationId"
    public static let PARAMETERS_KEY = "parameters"
    public static let RESPONSES_KEY = "responses"
    //https://swagger.io/docs/specification/paths-and-operations/
    public static let SUMMARY_KEY = "summary"
    public static let TAGS_KEY = "tags"
    public static let REQUEST_BODIES_KEY = "requestBody"
    public static let EXTERNAL_DOCS_KEY = "externalDocs"
    public static let DEPRECATED_KEY = "deprecated"
    public static let DESCRIPTION_KEY = "description"
    public static let SECURITY_KEY = "security"
    public var deprecated : Bool? = false
    public var operationId : String? = nil
    public var summary : String? = nil
    public var requestBody : OpenAPIRequestBody? = nil
    public var description : String? = nil
    public var tags : [String] = []
    public var responses : [OpenAPIResponse]? = []
    public var parameters : [OpenAPIParameter]? = []
    public var servers : [OpenAPIServer] = [OpenAPIServer(url: "/")]
    //Lists the required security schemes to execute this operation. The name used for each property MUST correspond to a security scheme declared in the Security Schemes under the Components Object.
    public var securityObjects : [OpenAPISecuritySchemeReference] = []
    public var extensions : [OpenAPIExtension]?
    public var externalDocs : OpenAPIExternalDocumentation? = nil
    public var userInfos =  [OpenAPIObject.UserInfo]()
  
    /// returns an OpenAPIResponse for the given HTTP Status  if declared on the operation or nil.
    public func response(httpstatus  status : String) -> OpenAPIResponse? {
        guard let responses else { return nil }
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
