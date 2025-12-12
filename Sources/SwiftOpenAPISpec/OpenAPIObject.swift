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
public struct OpenAPIObject  {
    public struct UserInfo : Codable {
        public let message : String
        public let infoType : UserInfoType
    }
    public enum UserInfoType : String, Codable {
        case error, warning, info
    }
    public enum Errors : LocalizedError {
        case invalidYaml(String), invalidSpecification(String, String), unsupportedSegment(String, String)
        public var errorDescription: String? {
            switch self {
            case .invalidYaml(let string):
                string
            case .invalidSpecification(let hierarchy, let key):
                "\(key) not found  in \(hierarchy) or does not contain expected elements"
            case .unsupportedSegment(let type, let segment):
                "\(type) does not contain expected element for \(segment)"
            }
        }
    }
   
    
    /**
            reads a textual representantation of an OpenAPI specification

             - Parameter text: the Yaml/JSON representation
             - Returns: an OpenAPISpec instance  which holds the text contents as simple Swift structs
     */
    
    public static func read(text : String) throws -> OpenAPIObject{
        guard let unflattened = try Yams.load(yaml: text) as? StringDictionary else {
            throw OpenAPIObject.Errors.invalidYaml("text cannot be interpreted as a Key/Value List")
        }
        let loadedDictionary = resolveMergeKeys(in: unflattened)
        //Mandatory
        let version = try loadedDictionary.tryRead(OpenAPIObject.OPENAPI_KEY, String.self, root: "root")
        //Mandatory
        let info = try loadedDictionary.tryMap(OpenAPIObject.INFO_KEY, root: "root", OpenAPIInfo.self)
        var spec = OpenAPIObject(version: version,info: info)
        spec.components =  try? loadedDictionary.tryMap(OpenAPIObject.COMPONENTS_KEY, root: "root", OpenAPIComponent.self)
        spec.selfUrl = loadedDictionary.readIfPresent(OpenAPIObject.SELF_URL_KEY, String.self)
        spec.tags = try loadedDictionary.tryListIfPresent(OpenAPIObject.TAGS_KEY, root: "root", OpenAPITag.self)
        spec.externalDocumentation = try loadedDictionary.tryMapIfPresent(OpenAPIObject.EXTERNAL_DOCS_KEY,root: "root", OpenAPIExternalDocumentation.self)
        spec.jsonSchemaDialect = loadedDictionary.tryReadIfPresent(OpenAPIObject.JSON_SCHEMA_DIALECT_KEY, String.self, root: "root")
        let servers =  try loadedDictionary.tryListIfPresent(OpenAPIObject.SERVERS_KEY, root: "root", OpenAPIServer.self)
        if servers.count > 0 {
            spec.servers = servers
        }
        if let map = loadedDictionary[OpenAPIObject.PATHS_KEY]  as? StringDictionary{
           let paths = try KeyedElementList<OpenAPIPathItem>.map(map)
            spec.paths = paths
        }
        if let map = loadedDictionary[OpenAPIObject.WEBHOOKS_KEY]  as? StringDictionary{
           let webhooks = try KeyedElementList<OpenAPIPathItem>.map(map)
            spec.webhooks  = webhooks
        }
        if let securityObjectMap = loadedDictionary[Self.SECURITY_KEY] as?  [[String:[String]]] {
            for element in securityObjectMap {
                if let mapElement = element.first {
                    let ref = OpenAPISecuritySchemeReference(key: mapElement.key, scopes:mapElement.value)
                    spec.securityObjects.append(ref)
                    
                }
            }
        }
        
            spec.extensions = try OpenAPIExtension.extensionElements(loadedDictionary)

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
    subscript(path path: String) -> OpenAPIPathItem? {
        return paths[path: path]
    }
    subscript(webhook path: String) -> OpenAPIPathItem? {
        return webhooks[path: path]
    }
    subscript(schemacomponent component: String) -> OpenAPISchema? {
        return components?.schemas?.first(where: { c in
            c.key == component
        })
    }
    subscript(parametercomponent component: String) -> OpenAPIParameter? {
        return components?.parameters?.first(where: { c in
            c.key == component
        })
    }
    subscript(responsecomponent component: String) -> OpenAPIResponse? {
        return components?.responses?.first(where: { c in
            c.key == component
        })
    }
    subscript(securityschemacomponent component: String) -> OpenAPISecurityScheme? {
        return components?.securitySchemas?.first(where: { c in
            c.key == component
        })
    }
    subscript(requestbodycomponent component: String) -> OpenAPIRequestBody? {
        return components?.requestBodies?.first(where:{ namedComponent in
            namedComponent.key == component
        }) as? OpenAPIRequestBody
    }
    
    

    /// Resolves YAML merge keys ("<<") in a structure produced by Yams.load.
    /// - Parameter any: The parsed YAML object (Dictionary/Array/Scalar).
    /// - Returns: A new object where merge keys are applied and removed.
    private static func resolveMergeKeys(_ any: Any) -> Any {
        switch any {
        case let dict as [String: Any]:
            return resolveMergeKeys(in: dict)
        case let array as [Any]:
            return array.map { resolveMergeKeys($0) }
        default:
            return any
        }
    }

    private static func resolveMergeKeys(in dict: [String: Any]) -> [String: Any] {
        // 1) First resolve merge keys in all non-merge children
        var resolved: [String: Any] = [:]
        resolved.reserveCapacity(dict.count)

        for (k, v) in dict where k != "<<" {
            resolved[k] = resolveMergeKeys(v)
        }

        // 2) Apply merges if present
        if let mergeValue = dict["<<"] {
            let mergedFrom = extractMergeMappings(mergeValue)
                .map { resolveMergeKeys(in: $0) } // resolve nested merges inside bases

            // YAML rule: merges are applied in order, later merges override earlier ones,
            // but explicit/local keys override everything.
            var base: [String: Any] = [:]
            for m in mergedFrom {
                base = deepMerge(base, m, preferSecond: true)
            }

            // 3) Finally merge local keys on top (locals win)
            resolved = deepMerge(base, resolved, preferSecond: true)
        }

        return resolved
    }

    /// Turns a merge-key value into an array of mappings.
    /// Valid YAML forms:
    ///   <<: *base
    ///   <<: [*base1, *base2]
    private static func extractMergeMappings(_ mergeValue: Any) -> [[String: Any]] {
        if let single = mergeValue as? [String: Any] {
            return [single]
        } else if let many = mergeValue as? [Any] {
            return many.compactMap { $0 as? [String: Any] }
        } else {
            // Non-mapping merge values are invalid per YAML spec;
            // we ignore them for robustness.
            return []
        }
    }

    /// Deep merges two dictionaries.
    /// - preferSecond: if true, values from `b` override those from `a`
    private static func deepMerge(_ a: [String: Any], _ b: [String: Any], preferSecond: Bool) -> [String: Any] {
        var result = a

        for (key, bVal) in b {
            if let aVal = result[key] {
                switch (aVal, bVal) {
                case (let aDict as [String: Any], let bDict as [String: Any]):
                    result[key] = deepMerge(aDict, bDict, preferSecond: preferSecond)

                case (let aArr as [Any], let bArr as [Any]):
                    // YAML doesn't define array-merge for <<; last wins is typical.
                    result[key] = preferSecond ? bArr : aArr

                default:
                    result[key] = preferSecond ? bVal : aVal
                }
            } else {
                result[key] = bVal
            }
        }

        return result
    }
    public func element(for segmentName : String) throws -> Any? {
        switch segmentName {
            case "components" : return self.components
            default : throw Self.Errors.unsupportedSegment("OpenAPIObject", segmentName)
        }
    }
    
    var userInfos =  [UserInfo]()
    static let COMPONENTS_KEY = "components"
    static let EXTERNAL_DOCS_KEY = "externalDocs"
    static let INFO_KEY = "info"
    static let JSON_SCHEMA_DIALECT_KEY = "$schema"
    static let OPENAPI_KEY = "openapi"
    static let PATHS_KEY = "paths"
    static let SECURITY_KEY = "security"
    static let SERVERS_KEY = "servers"
    static let TAGS_KEY = "tags"
    static let SELF_URL_KEY = "$self"
    static let WEBHOOKS_KEY = "webhooks"
    public var version : String
    public var selfUrl : String?
    public var jsonSchemaDialect : String?
    public var info : OpenAPIInfo
    public var servers : [OpenAPIServer] = []
    public private(set) var paths : [OpenAPIPathItem] = []
    public private(set) var webhooks : [OpenAPIPathItem] = []
    public var components : OpenAPIComponent?
    public var securityObjects : [OpenAPISecuritySchemeReference] = []
    public var externalDocumentation : OpenAPIExternalDocumentation?
    public var tags : [OpenAPITag] = []
    public var extensions : [OpenAPIExtension]?
    
    
}


struct OpenAPISpecification : Codable {
    
}

