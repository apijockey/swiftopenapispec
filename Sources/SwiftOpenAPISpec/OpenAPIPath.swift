//
//  File.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation


/***
  the pathKey includes a leading slash like /board
 */
struct OpenAPIPath: KeyedElement {
    var key: String? = nil
     
    var operations: [OpenAPIOperation] = []

    init(_ map: [AnyHashable : Any]) throws {
        
        
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
    subscript(httpMethod method: String) -> [OpenAPIOperation] {
        let matches = operations.filter { $0.key == method }
        return matches.isEmpty ? [] : matches
    }

    // Zugriff per operationId -> Liste oder nil
    subscript(operationId id: String) -> [OpenAPIOperation] {
        let matches = operations.filter { $0.operationId == id }
        return matches.isEmpty ? [] : matches
    }
}
extension Array where Element == OpenAPIPath  {
    // Zugriff per HTTP-Methode (get, post, put, ...) -> Liste oder nil
    subscript(httpMethod method: String) -> [OpenAPIOperation] {
        var matches : [OpenAPIOperation] = []
        for element in self {
            matches.append(contentsOf: element[httpMethod: method])
        }
        return matches.isEmpty ? [] : matches
        
    }

    // Zugriff per operationId -> Liste oder nil
    subscript(operationID id : String) -> [OpenAPIOperation] {
        var matches : [OpenAPIOperation] = []
        for element in self {
            matches.append(contentsOf: element[operationId: id])
        }
        return matches.isEmpty ? [] : matches
        
    }
    subscript(path path: String) -> [OpenAPIPath] {
        return self.filter { element in
            element.key == path
        }
        
        
    }
}
