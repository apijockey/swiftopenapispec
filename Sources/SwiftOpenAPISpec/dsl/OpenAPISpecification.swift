/*
 * Copyright 2025 CgSe Computergrafik und Softwareentwicklung GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
    
    public func element(for segmentName : String) throws ->  NavigationResult{
        switch segmentName {
            case Self.COMPONENTS_KEY : return .navigable(self.components)
            case Self.EXTERNAL_DOCS_KEY  : return .navigable(self.externalDocumentation)
            case Self.INFO_KEY : return .navigable(self.info)
            case Self.JSON_SCHEMA_DIALECT_KEY : return .value(JSONValue(string:self.jsonSchemaDialect))
            case Self.OPENAPI_KEY : return .value(JSONValue(string:self.version))
            case Self.PATHS_KEY : return .navigableCollection(self.paths)
            case Self.SECURITY_KEY :  return  .searchableCollection(self.securityObjects) // searchable
            case Self.SERVERS_KEY : return  .navigableCollection(self.servers)
            case Self.TAGS_KEY : return .navigableCollection(self.tags)
            case Self.SELF_URL_KEY : return .value(JSONValue(string:self.selfUrl))
        case Self.WEBHOOKS_KEY :return .navigableCollection(self.webhooks)
            
            default : throw Self.Errors.unsupportedSegment("OpenAPISpecification", segmentName)
        }
    }
    
    public var key: String?
    public var documentLoader : DocumentLoadable?
    
    /// initializes an OpenAPISpecification
    /// - Parameter unmerged: ``StringDictionary``
    /// public init(load map: StringDictionary throws {
    public init(load unmerged: StringDictionary,_ diagnostics: inout [Diagnostic]) throws {
        guard let dictionary  =  resolveMergeKeys(in: unmerged) as? StringDictionary else {
            throw OpenAPISpecification.Errors.invalidYaml("mergeKeys failed")
        
        }
       
        
        self.version = dictionary.readIfPresent(OpenAPISpecification.OPENAPI_KEY, valueType: String.self)
        self.info = try dictionary.readIfPresent(OpenAPISpecification.INFO_KEY, objectType: OpenAPIInfo.self)
        self.components = try dictionary.readIfPresent(OpenAPISpecification.COMPONENTS_KEY, objectType: OpenAPIComponent.self)
        self.selfUrl =  dictionary.readIfPresent(OpenAPISpecification.SELF_URL_KEY, valueType: String.self)
        self.key = selfUrl
        self.tags = try dictionary.mapListIfPresent(OpenAPISpecification.TAGS_KEY, objectType: OpenAPITag.self)
        self.externalDocumentation = try dictionary.readIfPresent(OpenAPISpecification.EXTERNAL_DOCS_KEY,objectType: OpenAPIExternalDocumentation.self)
        self.jsonSchemaDialect = dictionary.readIfPresent(OpenAPISpecification.JSON_SCHEMA_DIALECT_KEY, valueType: String.self)
        let servers =  try dictionary.mapListIfPresent(OpenAPISpecification.SERVERS_KEY, objectType: OpenAPIServer.self)
        if servers.count > 0 {
            self.servers = servers
            
        }
        self.paths   =  try dictionary.mapListIfPresent(OpenAPISpecification.PATHS_KEY, objectType: OpenAPIPathItem.self)
        self.webhooks = try dictionary.mapListIfPresent(OpenAPISpecification.WEBHOOKS_KEY, objectType: OpenAPIPathItem.self)
        self.securityObjects = try dictionary.mapListIfPresent(Self.SECURITY_KEY, objectType: OpenAPISecuritySchemeReference.self)
        
        
        self.extensions = try OpenAPIExtension.extensionElements(dictionary, &diagnostics)

       
        
       
    }
   
    /// Userinfo  holds information about validation or generation errors on each struct to simplify and streamline error handling and navigation
    
    public enum Errors : CustomStringConvertible, LocalizedError {
        public var description: String{
            switch self {
            case .invalidYaml(let string):
                return string
            case .invalidSpecification(let hierarchy, let key):
                return "required: field '\(key)' not found  in \(hierarchy) "
            case .unsupportedSegment(let type, let segment):
                return "\(type) does not contain expected element for \(segment)"
            case .notFound(let name): return "Fixture not found: \(name)"
            case .unreadable(let name, let err): return "Fixture unreadable: \(name) (\(err))"
            case .notUTF8(let name): return "Fixture not UTF-8 encoded: \(name)"
            
            case .invalidType(let type):
                return "invalid type \(type)"
            }
        }
        
        case invalidYaml(String), invalidSpecification(String, String), unsupportedSegment(String, String)
        case notFound(String)
       case invalidType(String)
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
        
        return  try await documentLoader.load(from: url)
        
    }
    
    
    /// reads a textual representantation of an OpenAPI specification starting with version
    /// - Parameters:
    ///   - unflattened: A ``StringDictionary`` representing the speicification in Yaml/JSON
    ///   - url: the url of the root file of the specifiation to use when dererencing JSON Pointer references, not required, if no JSONPointer references to other files are used.
    ///   - documentLoader: an implementation of ``DocumentLoadable`` or ``YamsDocumentLoader``if nil.
    /// - Returns: an OpenAPISpec instance  which holds the text contents as plain Swift structs
    /// sample code for usage:
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
    ///```
    public static func read(unflattened : StringDictionary, url : String? = nil , documentLoader : DocumentLoadable? = YamsDocumentLoader()) throws -> OpenAPISpecification{
        var diagnostics : [Diagnostic] = []
        do {
            var openapispec = try OpenAPISpecification(load: unflattened, &diagnostics)
            openapispec.documentLoader = documentLoader
            if openapispec.key == nil {
                openapispec.key = url
            }
            return openapispec
        }
        catch {
            throw Self.Errors.invalidSpecification(diagnostics.debugDescription, url ?? "")
        }
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
    ///   - component: the schema component name from the specification file
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
    ///  - component: the schema component name from the specification file
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
        - component: the response component name from the specification file
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
        - component: the schema component name from the specification file
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
        - component: the request body component name from the specification file
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
   
    
    
}


