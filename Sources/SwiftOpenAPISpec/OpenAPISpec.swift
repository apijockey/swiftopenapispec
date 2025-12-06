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




struct OpenAPISpec  {
    struct UserInfo : Codable {
        let message : String
        let infoType : UserInfoType
    }
    enum UserInfoType : String, Codable {
        case error, warning, info
    }
    enum Errors : LocalizedError {
        case invalidYaml(String), invalidSpecification(String, String)
        var errorDescription: String? {
            switch self {
            case .invalidYaml(let string):
                string
            case .invalidSpecification(let hierarchy, let key):
                "\(key) not found  in \(hierarchy) or does not contain expected elements"
            }
        }
    }
    var userInfos =  [UserInfo]()
    static let OPENAPI_KEY = "openapi"
    static let INFO_KEY = "info"
    static let SERVERS_KEY = "servers"
    static let PATHS_KEY = "paths"
    static let COMPONENTS_KEY = "components"
    var version : String
    var info : OpenAPIInfo
    var servers : [OpenAPIServer] = []
    var paths : [OpenAPIPath] = []
    var components : OpenAPIComponent? = nil
    func resolveComponent(_ text : String) {
        if text.starts(with: "#") {
            
        }
    }
    static func read(text : String) throws -> OpenAPISpec{
        guard let loadedDictionary = try Yams.load(yaml: text) as? [String:Any] else {
            throw OpenAPISpec.Errors.invalidYaml("text cannot be interpreted as a Key/Value List")
        }
        
        let version = try loadedDictionary.tryRead(OpenAPISpec.OPENAPI_KEY, String.self, root: "root")
        let info = try loadedDictionary.tryMap(OpenAPISpec.INFO_KEY, root: "root", OpenAPIInfo.self)
        var spec = OpenAPISpec(version: version,info: info)
        let servers =  try loadedDictionary.tryOptionalList(OpenAPISpec.SERVERS_KEY, root: "root", OpenAPIServer.self)
        if servers.count > 0 {
            spec.servers = servers
        }
        // I want the list of Paths
         
        if let map = loadedDictionary[OpenAPISpec.PATHS_KEY]  as? [AnyHashable:Any],
           let paths = try? MapListMap<OpenAPIPath>.map(map),
                paths.count > 0 {
                spec.paths = paths
        }
        
        spec.components =  try? loadedDictionary.tryMap(OpenAPISpec.COMPONENTS_KEY, root: "root", OpenAPIComponent.self)
        //TODO: Webhooks
        if spec.components == nil  && spec.paths.count == 0 {
            spec.userInfos.append(UserInfo(message: "components and paths element missing", infoType: .warning))
        }
       return spec
    }
    subscript(operationId id: String) -> [OpenAPIOperation] {
        let matches = paths[operationID: id]
        return matches.isEmpty ? [] : matches
    }
    subscript(httpMethod method: String) -> [OpenAPIOperation] {
        let matches = paths[httpMethod: method]
        return matches.isEmpty ? [] : matches
    }
    subscript(path path: String) -> [OpenAPIPath] {
        let matches = paths[path: path]
        return matches.isEmpty ? [] : matches
    }
    
    
}


struct OpenAPISpecification : Codable {
    
}

