// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

/// The OpenAPISpecification struct serves as an entry point to read your specification written in YAML or JSON
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
public struct OpenAPISpecification : KeyedElement , PointerNavigable, Sendable {
    public var key: String?
    public var documentLoader : DocumentLoadable?
    
    /// initializes an OpenAPISpecification
    /// - Parameter unmerged: ``StringDictionary``
    public init(_ unmerged: StringDictionary) throws {
        let map = resolveMergeKeys(in: unmerged)
        //Mandatory
        self.version = try map.tryRead(OpenAPISpecification.OPENAPI_KEY, String.self, root: "root")
        //Mandatory
        self.info = try map.tryMap(OpenAPISpecification.INFO_KEY, root: "root", OpenAPIInfo.self)
        if map[OpenAPISpecification.COMPONENTS_KEY]  as? StringDictionary != nil {
            components =  try map.tryMap(OpenAPISpecification.COMPONENTS_KEY, root: "root", OpenAPIComponent.self)
        }
        selfUrl = map.readIfPresent(OpenAPISpecification.SELF_URL_KEY, String.self)
        self.key = selfUrl
        tags = try map.tryListIfPresent(OpenAPISpecification.TAGS_KEY, root: "root", OpenAPITag.self)
        self.externalDocumentation = try map.tryMapIfPresent(OpenAPISpecification.EXTERNAL_DOCS_KEY,root: "root", OpenAPIExternalDocumentation.self)
        self.jsonSchemaDialect = map.tryReadIfPresent(OpenAPISpecification.JSON_SCHEMA_DIALECT_KEY, String.self, root: "root")
        let servers =  try map.tryListIfPresent(OpenAPISpecification.SERVERS_KEY, root: "root", OpenAPIServer.self)
        if servers.count > 0 {
            self.servers = servers
        }
        if let pathsMap = map[OpenAPISpecification.PATHS_KEY]  as? StringDictionary{
           let paths = try KeyedElementList<OpenAPIPathItem>.map(pathsMap)
            self.paths = paths
        }
        if let webhooksMap = map[OpenAPISpecification.WEBHOOKS_KEY]  as? StringDictionary{
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

       
        
       
    }
    
    /// Userinfo  holds information about validation or generation errors on each struct to simplify and streamline error handling and navigation
    
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
    
    /// Reads an OpenAPI specification from a given url using the provided document loader or the default ``YamsDocumentLoader``
    ///  - Parameters:
    ///   - url: a url to the specification (file, web)
    ///   - documentLoader: an instance implementing the ``DocumentLoadable`` protocol
    /// - Returns: an instance of ``OpenAPISpecification`` or throws an error
    ///
    /// ```swift
    ///  let url = URL(filePath:"/localurl/to/file.yaml")
    ///  let specFromURL = try await OpenAPISpecification.read(url: url,YamsDocumentLoader())
    /// ```
    public static func read(url : URL, documentLoader : DocumentLoadable? = YamsDocumentLoader()) async throws -> OpenAPISpecification {
        guard let documentLoader else { fatalError("no documentLoader provided") }
        

        var spec =  try await documentLoader.load(from: url)
        spec.documentLoader = documentLoader
        return spec
        
        
    }
    
    /// reads a textual representantation of an OpenAPI specification starting with version 3.0.0
    ///
    /// - Parameters:
    ///   - text: the Yaml/JSON representation
    ///   - url: the url of the root file of the specifiation to use when dererencing JSON Pointer references, not required, if no JSONPointer references to other files are used.
    /// - Returns: an OpenAPISpec instance  which holds the text contents as simple Swift structs
    ///
    ///sample code for usage:
    /// ```swift
    /// import Yams
    /// let yaml = """
    /// openapi: 3.0.0
    /// info:
    /// title: Simple API overview
    /// version: 2.0.0
    /// """
    ///guard let unflattened = try Yams.load(yaml: yaml) as? StringDictionary else {
    ///throw OpenAPISpecification.Errors.invalidYaml("text cannot be interpreted as a Key/Value List")
    ///}
    ///let specFromYaml = try OpenAPISpecification.read(unflattened: jsonMap)
    public static func read(unflattened : StringDictionary, url : String? = nil , documentLoader : DocumentLoadable? = YamsDocumentLoader()) throws -> OpenAPISpecification{
        var openapispec = try OpenAPISpecification(unflattened)
        openapispec.documentLoader = documentLoader
        if openapispec.key == nil {
            openapispec.key = url
        }
        return openapispec
    }
    /// Access a specific operation by its operation id
    ///
    /// In case operation ids are duplicated the subscript will return a list of matching elements indicating a specification error
    ///
    ///Code sample:
    /// ```swift
    ///let url = URL(string: "...")
    ///let specFromURL = try await OpenAPISpecification.read(url: url)
    ///let operation = specFromURL[operationId: "getPetsByID"].first
    /// ```
    public subscript(operationId id: String) -> [OpenAPIOperation] {
        let matches = paths[operationID: id]
        return matches.isEmpty ? [] : matches
    }
    
    /// Access all http methods in all paths elements with a given HTTP Method (GET,POST, PUT...)
    ///
    ///Helper/verification subscript to simplify completeness verification of supported HTTP Methods over all paths
    ///
    ///Code sample:
    /// ```swift
    ///let url = URL(string: "...")
    ///let specFromURL = try await OpenAPISpecification.read(url: url)
    ///let httpMethods = specFromURL[httpMethod: "GET"]
    /// ```
    public subscript(httpMethod method: String) -> [OpenAPIOperation] {
        let matches = paths[httpMethod: method]
        return matches.isEmpty ? [] : matches
    }
    ///access a Path item like _/getPetsById_
    ///
    ///- Parameters:
    ///  - path: a string
    ///- Returns:an ``OpenAPIPathItem`` or nil if none is found
    ///
    ///Code sample:
    /// ```swift
    ///let url = URL(string: "...")
    ///let specFromURL = try await OpenAPISpecification.read(url: url)
    ///let path = specFromURL[path: "/getPetsByID"]
    /// ```
    public  subscript(path path: String) -> OpenAPIPathItem? {
        return paths[path: path]
    }
    
    ///access a Webhook Path item like _orderCreated:_
    ///
    ///- Parameters:
    ///  - path: a string
    ///- Returns:an ``OpenAPIPathItem`` representing a webhook or nil if none is found
    ///
    ///Code sample:
    /// ```swift
    ///let url = URL(string: "...")
    ///let specFromURL = try await OpenAPISpecification.read(url: url)
    ///let webhook = specFromURL[webhook: "orderCreated"]
    /// ```
    public subscript(webhook path: String) -> OpenAPIPathItem? {
        return webhooks[path: path]
    }
    
    ///Access a schema component item like _orderCreated:_
    ///
    ///- Parameters:
    ///  - schemacomponent: the schema component name from the specification file
    ///- Returns:an ``OpenAPISchema``  or nil if none is found
    ///
    ///Assume, you have a schema compoent like this:
    ///Code sample:
    /// ```yaml
    /// components:
    ///   schemas:
    ///     User:
    ///       type: object
    ///       properties:
    ///         id:
    ///           type: string
    ///         email:
    ///           type: string
    ///           format: email
    ///       required: [id, email]
    ///  ```
    ///  You would access the schema component _User_ with this code:
    ///  ```swift
    ///let url = URL(string: "...")
    ///let specFromURL = try await OpenAPISpecification.read(url: url)
    ///let userComponent = specFromURL[schemacomponent: "User"]
    ///```
    public subscript(schemacomponent component: String) -> OpenAPISchema? {
        return components?.schemas?.first(where: { c in
            c.key == component
        })
    }
    
    ///Access a parameter component item like _skipParam_
    ///
    ///- Parameters:
    ///  - parametercomponent: the schema component name from the specification file
    ///- Returns:an ``OpenAPIParameter``  or nil if none is found
    ///
    ///Assume, you have a schema compoent like this:
    ///Code sample:
    /// ```yaml
    /// components:
///        parameters:
///              skipParam:
///                name: skip
///                in: query
///                description: number of items to skip
///                required: true
///                schema:
///                  type: integer
///                  minimum: 0
///                  default: 0
///              limitParam:
///                name: limit
///                in: query
///                description: max number of items to return
///                required: false
///                schema:
///                  type: integer
///                  minimum: 1
///                  maximum: 100
///                  default: 10
    ///  ```
    ///  You would access the schema component _User_ with this code:
    ///  ```swift
    ///let url = URL(string: "...")
    ///let specFromURL = try await OpenAPISpecification.read(url: url)
    ///let skipParameter = specFromURL[parametercomponent: "skipParam"]
    ///```
    public subscript(parametercomponent component: String) -> OpenAPIParameter? {
        return components?.parameters?.first(where: { c in
            c.key == component
        })
    }
    /**
     Access a response component item like _ImageResponse_
     
      - Parameters:
        - responsecomponent: the response component name from the specification file
      -  returns:an ``OpenAPIResponse``  or nil if none is found
    
    Assume, you have a schema compoent like this:
     ```yaml
       responses:
         NotFound:
           description: Entity not found.
         ImageResponse:     # Can be referenced as '#/components/responses/ImageResponse'
           description: An image.
           content:
             image:
         IllegalInput:
           description: Illegal input for operation.
         GeneralError:
           description: General Error
           content:
             application/json:
               schema:
                 $ref: '#/components/schemas/GeneralError'
   
      ```
      You would access the schema component _User_ with this code:
      ```swift
    let url = URL(string: "...")
    let specFromURL = try await OpenAPISpecification.read(url: url)
    let skipParameter = specFromURL[parametercomponent: "ImageResponse"]
    ```
    */
    public subscript(responsecomponent component: String) -> OpenAPIResponse? {
        return components?.responses?.first(where: { c in
            c.key == component
        })
    }
    
    
    /**
     Access a security schema component item like _http_Key_
     
      - Parameters:
        - securityschemacomponent: the schema component name from the specification file
      -  returns:an ``OpenAPISecurityScheme``  or nil if none is found
    
    Assume, you have security schema compoents like this:
     ```yaml
     securitySchemes:
       http_Key:
         type: http
         scheme: basic
       api_key:
         type: apiKey
         name: api_key
         in: header
       bearer_key:
         type: http
         scheme: bearer
         bearerFormat: JWT
       petstore_auth:
         type: oauth2
         flows:
           implicit:
             authorizationUrl: https://example.org/api/oauth/dialog
             scopes:
               write:pets: modify pets in your account
               read:pets: read your pets
       clip_auth:
         type: oauth2
         flows:
           implicit:
             authorizationUrl: https://example.com/api/oauth/dialog
             scopes:
               write:pets: modify pets in your account
               read:pets: read your pets
           authorizationCode:
             authorizationUrl: https://example.com/api/oauth/dialog
             tokenUrl: https://example.com/api/oauth/token
             scopes:
               write:clips: modify pets in your account
               read:clips: read your pets
   
      ```
      You would access the schema component _User_ with this code:
      ```swift
    let url = URL(string: "...")
    let specFromURL = try await OpenAPISpecification.read(url: url)
    let skipParameter = specFromURL[securityschemacomponent: "http_Key"]
    ```
    */
    public subscript(securityschemacomponent component: String) -> OpenAPISecurityScheme? {
        return components?.securitySchemas?.first(where: { c in
            c.key == component
        })
    }
    
    
    /**
     Access a requestbodycomponent item like _http_Key_
     
      - Parameters:
        - requestbodycomponent: the request body component name from the specification file
      -  returns:an ``OpenAPIRequestBody``  or nil if none is found
    
    Assume, you have security schema compoents like this:
     ```yaml
     requestBodies:
       CreateUserRequest:
         description: JSON-Payload für das Anlegen eines Users
         required: true
         content:
           application/json:
             schema:
               $ref: "#/components/schemas/User"
             # MediaType + Example-Ref
             examples:
               userExample:
                 $ref: "#/components/examples/UserExample"
      ```
      You would access the schema component _User_ with this code:
      ```swift
    let url = URL(string: "...")
    let specFromURL = try await OpenAPISpecification.read(url: url)
    let skipParameter = specFromURL[requestbodycomponent: "CreateUserRequest"]
    ```
    */
    public subscript(requestbodycomponent component: String) -> OpenAPIRequestBody? {
        return components?.requestBodies?.first(where:{ namedComponent in
            namedComponent.key == component
        }) as? OpenAPIRequestBody
    }
    
    

    /// Resolves YAML merge keys ("<<") in a structure produced by Yams.load.
    /// - Parameter any: The parsed YAML object (Dictionary/Array/Scalar).
    /// - Returns: A new object where merge keys are applied and removed.
    private func resolveMergeKeys(_ any: Any) -> Any {
        switch any {
        case let dict as [String: Any]:
            return resolveMergeKeys(in: dict)
        case let array as [Any]:
            return array.map { resolveMergeKeys($0) }
        default:
            return any
        }
    }

    private func resolveMergeKeys(in dict: [String: Any]) -> [String: Any] {
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
    private func extractMergeMappings(_ mergeValue: Any) -> [[String: Any]] {
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
    private func deepMerge(_ a: [String: Any], _ b: [String: Any], preferSecond: Bool) -> [String: Any] {
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
            
            default : throw Self.Errors.unsupportedSegment("OpenAPISpecification", segmentName)
        }
    }
    
  
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
    public var version : String? = "3.2.0"
    public var selfUrl : String?
  
    public var jsonSchemaDialect : String?
    public var info : OpenAPIInfo?
    public var servers : [OpenAPIServer] = []
    public private(set) var paths : [OpenAPIPathItem] = []
    public private(set) var webhooks : [OpenAPIPathItem] = []
    public var components : OpenAPIComponent?
    public var securityObjects : [OpenAPISecuritySchemeReference] = []
    public var externalDocumentation : OpenAPIExternalDocumentation?
    public var tags : [OpenAPITag] = []
    public var extensions : [OpenAPIExtension]?
    public var ref: OpenAPISchemaReference? { nil}
    
    
}

// MARK: - Encoding to StringDictionary

extension OpenAPISpecification: ThrowingHashMapEncodable {
    public func toDictionary() throws -> StringDictionary {
        var dict: StringDictionary = [:]

        // Required
        dict[Self.OPENAPI_KEY] = version

        // info
        if let infoEnc = info as? ThrowingHashMapEncodable {
            dict[Self.INFO_KEY] = try infoEnc.toDictionary()
        } else {
            // Fallback: minimal info map
            dict[Self.INFO_KEY] = ["title": info?.title, "version": info?.version]
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



