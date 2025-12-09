//
//  File.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation


/**
  Struct containing an **OpenAPI Path Item** containing endpoints and their ``operations``
   
 Describes the operations available on a single path. A Path Item MAY be empty, due to ACL constraints. The path itself is still exposed to the documentation viewer but they will not know which operations and parameters are available.
 
   
 */
public struct OpenAPIPathItem: KeyedElement {
    public var key: String?
    
    /// holds the relative path to an individual endpoint, beginning with a leading slash
    /// ```swift
    /// //example
    /// "/ping"
    public static let SUMMARY_KEY = "summary"
    public static let DESCRIPTION_KEY = "description"
    
    /// inits an instance of ``OpenAPIPathItem``
    /// - Parameter map: Swift dictionary with a Path key and  value elements representing HTTP methods like **GET**, **POST** and **PUT**
    public init(_ map: [AnyHashable : Any]) throws {
        // one resource may foresee several httpOperations
        self.summary = map[Self.SUMMARY_KEY] as? String
        self.description = map[Self.DESCRIPTION_KEY] as? String
        for (key, httpOperation) in map {
            if let httpOperationMap = httpOperation as? [AnyHashable: Any] {
                var operation = try OpenAPIOperation(httpOperationMap)
                if let operationId = key as? String {
                    // In diesem Kontext ist "key" die HTTP-Methode (get, post, ...)
                    operation.key = operationId
                }
                self.operations.append(operation)
            }
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
    public var summary: String? = nil
    public var description: String? = nil
    public var operations: [OpenAPIOperation] = []
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
    subscript(webhook path: String) -> OpenAPIPathItem? {
        return self.first(where: { $0.key == path })
    }
    
    
}
