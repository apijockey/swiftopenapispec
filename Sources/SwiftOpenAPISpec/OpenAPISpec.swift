// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Yams

//https://swiftpackageindex.com/apple/swift-openapi-generator/1.2.1/tutorials/swift-openapi-generator/clientswiftpm
struct S: Codable {
    var p: String
}
//https://github.com/jpsim/Yams

//https://swagger.io/docs/specification/components/



///
/// OpenAPI is a specification format for REST/JSON based webservices.
///
///  The struct OpenAPISpec reads the textual representation written in the Yaml/JSON format and provides convenient access to all definitions in the specification.
/// https://spec.openapis.org/oas/latest.html
///
/// To consume a Yaml/JSON representation of an OpenAPI specification, call the static `read` function:
/// ```swift
/// let text = """
///openapi: 3.1.0
///info:
///  title: A minimal OpenAPI Description
///  version: 0.0.1
///paths: {}
/// """
/// let apiSpec = try OpenAPISpec.read(text: string)
/// ```
///
public struct OpenAPISpec  {
    public struct UserInfo : Codable {
        public let message : String
        public let infoType : UserInfoType
    }
    public enum UserInfoType : String, Codable {
        case error, warning, info
    }
    public enum Errors : LocalizedError {
        case invalidYaml(String), invalidSpecification(String, String)
        public var errorDescription: String? {
            switch self {
            case .invalidYaml(let string):
                string
            case .invalidSpecification(let hierarchy, let key):
                "\(key) not found  in \(hierarchy) or does not contain expected elements"
            }
        }
    }
    var userInfos =  [UserInfo]()
    static let COMPONENTS_KEY = "components"
    static let externalDocs_KEY = "components"
    static let INFO_KEY = "info"
    static let JSON_SCHEMA_DIALECT_KEY = "$schema"
    static let OPENAPI_KEY = "openapi"
    static let PATHS_KEY = "paths"
    static let SECURITY_KEY = "security"
    static let SERVERS_KEY = "servers"
    static let TAGS_KEY = "tags"
    static let SELF_URL_KEY = "$self"
    static let WEBHOOKS_KEY = "webhooks"
    var version : String
    var info : OpenAPIInfo
    var servers : [OpenAPIServer] = []
    public private(set) var paths : [OpenAPIPath] = []
    public private(set) var webhooks : [OpenAPIPathItem] = []
    var components : OpenAPIComponent?
    func resolveComponent(_ text : String) {
        if text.starts(with: "#") {
            
        }
    }
    /**
            reads a textual representantation of an OpenAPI specification

             - Parameter text: the Yaml/JSON representation
             - Returns: an OpenAPISpec instance  which holds the text contents as simple Swift structs
     */
    
    public static func read(text : String) throws -> OpenAPISpec{
        guard let loadedDictionary = try Yams.load(yaml: text) as? [String:Any] else {
            throw OpenAPISpec.Errors.invalidYaml("text cannot be interpreted as a Key/Value List")
        }
        //Mandatory
        let version = try loadedDictionary.tryRead(OpenAPISpec.OPENAPI_KEY, String.self, root: "root")
        //Mandatory
        let info = try loadedDictionary.tryMap(OpenAPISpec.INFO_KEY, root: "root", OpenAPIInfo.self)
        var spec = OpenAPISpec(version: version,info: info)
        spec.components =  try? loadedDictionary.tryMap(OpenAPISpec.COMPONENTS_KEY, root: "root", OpenAPIComponent.self)
        
        
        let servers =  try loadedDictionary.tryOptionalList(OpenAPISpec.SERVERS_KEY, root: "root", OpenAPIServer.self)
        if servers.count > 0 {
            spec.servers = servers
        }
        
        //TODO: Webhooks
        if let map = loadedDictionary[OpenAPISpec.WEBHOOKS_KEY]  as? [String:Any],
           let webhooks = try? MapListMap<OpenAPIPathItem>.map(map),
                webhooks.count > 0 {
            spec.webhooks  = webhooks
        }
        
       
         
        if let map = loadedDictionary[OpenAPISpec.PATHS_KEY]  as? [AnyHashable:Any],
           let paths = try? MapListMap<OpenAPIPath>.map(map),
                paths.count > 0 {
                spec.paths = paths
        }
        //https://swagger.io/docs/specification/v3_0/components/
        if spec.components == nil  && spec.paths.count == 0 && spec.webhooks.count == 0 {
            spec.userInfos.append(UserInfo(message: "components and paths element missing", infoType: .warning))
        }
        
       return spec
    }
    public subscript(operationId id: String) -> [OpenAPIOperation] {
        let matches = paths[operationID: id]
        return matches.isEmpty ? [] : matches
    }
    public subscript(httpMethod method: String) -> [OpenAPIOperation] {
        let matches = paths[httpMethod: method]
        return matches.isEmpty ? [] : matches
    }
    subscript(path path: String) -> OpenAPIPath? {
        return paths[path: path]
    }
    subscript(webhook path: String) -> OpenAPIPathItem? {
        return webhooks[webhook: path]
    }
    subscript(schemacomponent component: String) -> OpenAPISchema? {
        return components?.schemas.first(where: { c in
            c.key == component
        })?.namedComponentType
    }
    subscript(parametercomponent component: String) -> OpenAPIParameter? {
        return components?.parameters.first(where: { c in
            c.key == component
        })?.namedComponentType
    }
    subscript(responsecomponent component: String) -> OpenAPIResponse? {
        return components?.responses.first(where: { c in
            c.key == component
        })
    }
    subscript(securityschemacomponent component: String) -> OpenAPISecurityScheme? {
        return components?.securitySchemas.first(where: { c in
            c.key == component
        })
    }
    
    
    
}


struct OpenAPISpecification : Codable {
    
}

