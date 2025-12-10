//
//  File 2.swift
//  
//
//  Created by Patric Dubois on 29.03.24.
//

import Foundation


public struct OneOfSchemas : ThrowingHashMapInitiable {
    public init(_ map: [AnyHashable : Any]) throws {
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
    
    public var schemas : [OpenAPISchema] = []
     public var schemaRefs : [OpenAPISchemaReference] = []
    public var userInfos =  [OpenAPIObject.UserInfo]()
}
