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
public struct OpenAPIPath: KeyedElement {
    /// holds the relative path to an individual endpoint, beginning with a leading slash
    /// ```swift
    /// //example
    /// "/ping"
    public var key: String? = nil
     
    public var operations: [OpenAPIOperation] = []
    
    /// inits an instance of ``OpenAPIPath``
    /// - Parameter map: Swift dictionary with a Path key and  value elements representing HTTP methods like **GET**, **POST** and **PUT**
    public init(_ map: [AnyHashable : Any]) throws {
        // one resource may foresee several httpOperations
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
}


public extension Array where Element == OpenAPIPath  {
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
    subscript(path path: String) -> OpenAPIPath? {
        return self.first(where: { $0.key == path })
    }
   
}
