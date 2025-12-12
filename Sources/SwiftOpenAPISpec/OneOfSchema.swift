//
//  File 2.swift
//  
//
//  Created by Patric Dubois on 29.03.24.
//

import Foundation


//public struct OneOfSchemas : ThrowingHashMapInitiable {
//    
//    public static let REF_KEY = "$ref"
//    
//    public init(_ map: [String : Any]) throws {
//        let typelist  = map["oneOf"] as? [Any] ?? []
//        for element in typelist {
//            if let elementMap = element as? StringDictionary,
//               elementMap[Self.REF_KEY] as? String != nil,
//                let reference = try? OpenAPISchemaReference(elementMap) {
//                schemaRefs.append(reference)
//            }
//            else if let elementMap = element as? StringDictionary,
//                    let schema = try? OpenAPISchema(elementMap){
//                            schemas.append(schema)
//            }
//        }
//    }
//    
//    public var schemas : [OpenAPISchema] = []
//     public var schemaRefs : [OpenAPISchemaReference] = []
//    public var userInfos =  [OpenAPIObject.UserInfo]()
//}
