//
//  File.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation
struct OpenAPIPath : KeyedElement{
    var key: String? = nil
    init(_ map: [AnyHashable : Any]) throws {
        // one resource may foresee several httpOperations
        for (key,httpOperation) in map {
            if let httpOperationMap = httpOperation as? [AnyHashable:Any] {
                var operation = try OpenAPIOperation(httpOperationMap)
                if let operationId = key as? String {
                    operation.key = operationId
                }
                self.operations.append(operation)
            }
        }
      
    }
    var operations: [OpenAPIOperation] = []
}

