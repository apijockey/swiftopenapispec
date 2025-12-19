//
//  File.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation


/**
  Struct containing an **OpenAPI Path** containing endpoints and their ``operations``
   
   The ``OpenAPIPath`` provides a set of convenient getter subscripts to filter for specific operations
 
   
 */
public struct OpenAPIPathItem: KeyedElement , PointerNavigable {
   
    
    public enum Operations: String, Codable {
        case get, post, put, delete, options, head, patch, trace, query
    }
    
   
    public static let SUMMARY_KEY = "summary"
    public static let DESCRIPTION_KEY = "description"
    public static let SERVERS_KEY = "servers"
    public static let PARAMETERS_KEY = "parameters"
    public static let ADDITIONAL_OPERATIONS_KEY = "additionalOperations"
    
    /// holds the relative path to an individual endpoint, beginning with a leading slash
    /// ```swift
    /// //example
    /// "/ping"
    /// inits an instance of ``OpenAPIPath``
    /// - Parameter map: Swift dictionary with a Path key and  value elements representing HTTP methods like **GET**, **POST** and **PUT**
    public init(_ map: [String: Any]) throws {
        // one resource may foresee several httpOperations
        for (key, httpOperation) in map {
            if Self.Operations(rawValue: key) != nil,
               let httpOperationMap = httpOperation as? [String: Any] {
                var operation = try OpenAPIOperation(httpOperationMap)
                operation.key = key
                self.operations.append(operation)
            }
        }
        if let refMap = map[OpenAPISchemaReference.REF_KEY] as? StringDictionary {
                    self.ref = try OpenAPISchemaReference(refMap)
                }
        if let ref = map[OpenAPISchemaReference.REF_KEY] as? String {
                    self.ref = OpenAPISchemaReference(ref: ref)
        }
        self.summary  = map.readIfPresent(Self.SUMMARY_KEY, String.self)
        self.description  = map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
        let servers = try map.tryListIfPresent(OpenAPISpecification.SERVERS_KEY, root: "OpenAPIPath", OpenAPIServer.self)
        if servers.count > 0 {
            self.servers = servers
        }
        let parameters = try map.tryListIfPresent(Self.PARAMETERS_KEY, root: "OpenAPIPath", OpenAPIParameter.self)
        if parameters.count > 0 {
            self.parameters = parameters
        }
        if let additionalOperationsMap = map[Self.ADDITIONAL_OPERATIONS_KEY] as? StringDictionary {
            self.additionalOperations = try KeyedElementList<OpenAPIOperation>.map(additionalOperationsMap)
        }
        self.extensions = try OpenAPIExtension.extensionElements(map)
    }
    public func element(for segmentName: String) throws -> Any? {
        switch segmentName {
           
            case Self.SUMMARY_KEY: return summary
            case Self.DESCRIPTION_KEY: return description
            case Self.SERVERS_KEY: return servers
            case Self.PARAMETERS_KEY: return parameters
            case Self.ADDITIONAL_OPERATIONS_KEY: return additionalOperations
            case OpenAPISchemaReference.REF_KEY: return ref
            default :
            if let operation = operations[key: segmentName] {
                return operation
            }
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIPathItem", segmentName)
        }
    }
    // Zugriff per HTTP-Methode (get, post, put, ...) -> Liste oder nil
    public subscript(httpMethod method: String) -> [OpenAPIOperation] {
        let matches = operations.filter { $0.key == method }
        return matches.isEmpty ? [] : matches
    }

    // Zugriff per operationId -> Liste oder nil
    public subscript(operationId id: String) -> [OpenAPIOperation] {
        let matches = operations.filter { $0.operationId == id }
        return matches.isEmpty ? [] : matches
    }
    public var additionalOperations: [OpenAPIOperation] = []
    public var description :String? = nil
    public var key: String? = nil
    public var extensions : [OpenAPIExtension] = []
    public var operations: [OpenAPIOperation] = []
    public var parameters: [OpenAPIParameter] = []
    public var ref : OpenAPISchemaReference? = nil
    public var servers: [OpenAPIServer] = []
    public var summary: String? = nil
    public var userInfos =  [OpenAPISpecification.UserInfo]()
}


public extension Array where Element == OpenAPIPathItem  {
    // Zugriff per HTTP-Methode (get, post, put, ...) -> Liste oder nil
    subscript(httpMethod method: String) -> [OpenAPIOperation] {
        var matches : [OpenAPIOperation] = []
        for element in self {
            matches.append(contentsOf: element[httpMethod: method])
        }
        return matches.isEmpty ? [] : matches
        
    }

    /// Access an ``OpenAPIOperation`` based on its unique  ``OpenAPIOperation/operationId``.
     subscript(operationID id : String) -> [OpenAPIOperation] {
        var matches : [OpenAPIOperation] = []
        for element in self {
            matches.append(contentsOf: element[operationId: id])
        }
        return matches.isEmpty ? [] : matches
        
    }
    /// search for a **path** declaration
     ///
    /// An OpenAPI specification may hold a list of **Path** elements. The subscript provides an easy access to a list of matching ``OpenAPIPath`` elements for that **path** string.
    ///
    /// - Parameters: an OpenApi path string, starting with a slash.
    /// - Returns: a list of  OpenAPIPath structs matching the search **path** string
    ///
    /// ```swift
    /// // sample search for the Path declaration for /ping
    ///  let openAPIPath = apiSpec[path: "/ping"]
    /// ```
    ///
    subscript(path path: String) -> OpenAPIPathItem? {
        return self.first(where: { $0.key == path })
    }
   
    
   
}
