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
public struct OpenAPIObject : KeyedElement , PointerNavigable {
    public var key: String?
    
    public init(_ map: StringDictionary) throws {
        //Mandatory
        self.version = try map.tryRead(OpenAPIObject.OPENAPI_KEY, String.self, root: "root")
        //Mandatory
        self.info = try map.tryMap(OpenAPIObject.INFO_KEY, root: "root", OpenAPIInfo.self)
        if map[OpenAPIObject.COMPONENTS_KEY]  as? StringDictionary != nil {
            components =  try map.tryMap(OpenAPIObject.COMPONENTS_KEY, root: "root", OpenAPIComponent.self)
        }
        selfUrl = map.readIfPresent(OpenAPIObject.SELF_URL_KEY, String.self)
        self.key = selfUrl
        tags = try map.tryListIfPresent(OpenAPIObject.TAGS_KEY, root: "root", OpenAPITag.self)
        self.externalDocumentation = try map.tryMapIfPresent(OpenAPIObject.EXTERNAL_DOCS_KEY,root: "root", OpenAPIExternalDocumentation.self)
        self.jsonSchemaDialect = map.tryReadIfPresent(OpenAPIObject.JSON_SCHEMA_DIALECT_KEY, String.self, root: "root")
        let servers =  try map.tryListIfPresent(OpenAPIObject.SERVERS_KEY, root: "root", OpenAPIServer.self)
        if servers.count > 0 {
            self.servers = servers
        }
        if let pathsMap = map[OpenAPIObject.PATHS_KEY]  as? StringDictionary{
           let paths = try KeyedElementList<OpenAPIPathItem>.map(pathsMap)
            self.paths = paths
        }
        if let webhooksMap = map[OpenAPIObject.WEBHOOKS_KEY]  as? StringDictionary{
           let webhooks = try KeyedElementList<OpenAPIPathItem>.map(webhooksMap)
            self.webhooks  = webhooks
        }
        if let securityObjectMap = map[Self.SECURITY_KEY] as?  [[String:[String]]] {
            for element in securityObjectMap {
                if let mapElement = element.first {
                    let ref = OpenAPISecuritySchemeReference(key: mapElement.key, scopes:mapElement.value)
                    self.securityObjects.append(ref)
                    
                }
            }
        }
        
        self.extensions = try OpenAPIExtension.extensionElements(map)

        //https://swagger.io/docs/specification/v3_0/components/
        if self.components == nil  && self.paths.count == 0 && self.webhooks.count == 0 {
            self.userInfos.append(UserInfo(message: "components and paths element missing", infoType: .warning))
        }
        
       
    }
    
    public struct UserInfo : Codable {
        public let message : String
        public let infoType : UserInfoType
    }
    public enum UserInfoType : String, Codable {
        case error, warning, info
    }
    public enum Errors : CustomStringConvertible, LocalizedError {
        public var description: String{
            switch self {
            case .invalidYaml(let string):
                return string
            case .invalidSpecification(let hierarchy, let key):
                return "\(key) not found  in \(hierarchy) or does not contain expected elements"
            case .unsupportedSegment(let type, let segment):
                return "\(type) does not contain expected element for \(segment)"
            case .notFound(let name): return "Fixture not found: \(name)"
            case .unreadable(let name, let err): return "Fixture unreadable: \(name) (\(err))"
            case .notUTF8(let name): return "Fixture not UTF-8 encoded: \(name)"
            
            }
        }
        
        case invalidYaml(String), invalidSpecification(String, String), unsupportedSegment(String, String)
        case notFound(String)
       
        case unreadable(String, Error)
        case notUTF8(String)
        public var errorDescription: String? {
            return description
        }
    }
   
    
    /**
            reads a textual representantation of an OpenAPI specification

             - Parameter text: the Yaml/JSON representation
             - Returns: an OpenAPISpec instance  which holds the text contents as simple Swift structs
     */
    
    public static func read(text : String, url : String ) throws -> OpenAPIObject{
        guard let unflattened = try Yams.load(yaml: text) as? StringDictionary else {
            throw OpenAPIObject.Errors.invalidYaml("text cannot be interpreted as a Key/Value List")
        }
        let loadedDictionary = resolveMergeKeys(in: unflattened)
        var openapispec = try OpenAPIObject(loadedDictionary)
        if openapispec.key == nil {
            openapispec.key = url
        }
        return openapispec
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
            case Self.COMPONENTS_KEY : return self.components
            case Self.EXTERNAL_DOCS_KEY  : return self.externalDocumentation
            case Self.INFO_KEY : return self.info
            case Self.JSON_SCHEMA_DIALECT_KEY : return self.jsonSchemaDialect
            case Self.OPENAPI_KEY : return self.version
            case Self.PATHS_KEY : return self.paths
            case Self.SECURITY_KEY :  return self.securityObjects
            case Self.SERVERS_KEY : return self.servers
            case Self.TAGS_KEY : return self.tags
            case Self.SELF_URL_KEY : return self.selfUrl
            case Self.WEBHOOKS_KEY :return self.webhooks
            
            default : throw Self.Errors.unsupportedSegment("OpenAPIObject", segmentName)
        }
    }
    
    public var userInfos =  [UserInfo]()
    public static let COMPONENTS_KEY = "components"
    public static let EXTERNAL_DOCS_KEY = "externalDocs"
    public static let INFO_KEY = "info"
    public static let JSON_SCHEMA_DIALECT_KEY = "$schema"
    public static let OPENAPI_KEY = "openapi"
    public static let PATHS_KEY = "paths"
    public static let SECURITY_KEY = "security"
    public static let SERVERS_KEY = "servers"
    public static let TAGS_KEY = "tags"
    public static let SELF_URL_KEY = "$self"
    public static let WEBHOOKS_KEY = "webhooks"
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

// MARK: - Encoding to StringDictionary

extension OpenAPIObject: ThrowingHashMapEncodable {
    public func toDictionary() throws -> StringDictionary {
        var dict: StringDictionary = [:]

        // Required
        dict[Self.OPENAPI_KEY] = version

        // info
        if let infoEnc = info as? ThrowingHashMapEncodable {
            dict[Self.INFO_KEY] = try infoEnc.toDictionary()
        } else {
            // Fallback: minimal info map
            dict[Self.INFO_KEY] = ["title": info.title, "version": info.version]
        }

        // $schema
        try encodeKey(Self.JSON_SCHEMA_DIALECT_KEY, value: jsonSchemaDialect, into: &dict)

        // $self
        try encodeKey(Self.SELF_URL_KEY, value: selfUrl, into: &dict)

        // externalDocs
        if let ext = externalDocumentation as? ThrowingHashMapEncodable {
            _ = try encodeKey(Self.EXTERNAL_DOCS_KEY, encodable: ext, into: &dict)
        } else if let extDoc = externalDocumentation {
            dict[Self.EXTERNAL_DOCS_KEY] = ["url": extDoc.url, "description": extDoc.description as Any].compactMapValues { $0 }
        }

        // servers (array of maps)
        if let serversEnc = servers as? [ThrowingHashMapEncodable] {
            dict[Self.SERVERS_KEY] = try serversEnc.map { try $0.toDictionary() }
        } else {
            // best-effort: map servers minimally
            if !servers.isEmpty {
                dict[Self.SERVERS_KEY] = servers.map { ["url": $0.url, "description": $0.description as Any].compactMapValues { $0 } }
            }
        }

        // tags (array of maps)
        if let tagsEnc = tags as? [ThrowingHashMapEncodable] {
            dict[Self.TAGS_KEY] = try tagsEnc.map { try $0.toDictionary() }
        } else if !tags.isEmpty {
            dict[Self.TAGS_KEY] = tags.map { tag in
                var t: [String: Any] = ["name": tag.name as Any,
                                        "summary": tag.summary as Any,
                                        "description": tag.description as Any]
                // extensions for tags
                encodeExtensions(tag.extensions, into: &t)
                return t.compactMapValues { $0 }
            }
        }

        // security: [[String: [String]]]
        if !securityObjects.isEmpty {
            let arr = securityObjects.map { ref -> [String: [String]] in
                let name = ref.key ?? ""
                return [name: ref.scopes]
            }
            dict[Self.SECURITY_KEY] = arr
        }

        // paths: [String: PathItem] Patric: 14.12.2025 für später
        //_ = try encodeMapFromKeyedArray(Self.PATHS_KEY, array: paths as? [any (KeyedElement & ThrowingHashMapEncodable)] as? [OpenAPIPathItem], into: &dict)

        // paths: [String: PathItem] Patric: 14.12.2025 für später
        // webhooks: [String: PathItem]
        //_ = try encodeMapFromKeyedArray(Self.WEBHOOKS_KEY, array: webhooks as? [any (KeyedElement & ThrowingHashMapEncodable)] as? [OpenAPIPathItem], into: &dict)

        // components
        if let comp = components as? ThrowingHashMapEncodable {
            dict[Self.COMPONENTS_KEY] = try comp.toDictionary()
        } else if components != nil{
            // minimal fallback if not encodable yet
            let c: [String: Any] = [:]
            // You can expand this as soon as OpenAPIComponent conforms to ThrowingHashMapEncodable
            dict[Self.COMPONENTS_KEY] = c
        }

        // x-* extensions at root
        encodeExtensions(extensions, into: &dict)

        return dict
    }
}


struct OpenAPISpecification : Codable {
    
}

