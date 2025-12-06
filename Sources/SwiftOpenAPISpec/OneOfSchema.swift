//
//  File 2.swift
//  
//
//  Created by Patric Dubois on 29.03.24.
//

import Foundation


struct OneOfSchemas : ThrowingHashMapInitiable {
    init(_ map: [AnyHashable : Any]) throws {
        let typelist  = map["oneOf"] as? [Any] ?? []
        for element in typelist {
            if let elementMap = element as? [AnyHashable:Any],
               elementMap["$ref"] as? String != nil,
                let reference = try? OpenAPISchemaReference(elementMap) {
                schemaRefs.append(reference)
            }
            else if let elementMap = element as? [AnyHashable:Any],
                    let schema = try? OpenAPISchema(elementMap){
                            schemas.append(schema)
            }
        }
    }
    
    var schemas : [OpenAPISchema] = []
    var schemaRefs : [OpenAPISchemaReference] = []
}
