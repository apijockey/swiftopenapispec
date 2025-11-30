//
//  File.swift
//  
//
//  Created by Patric Dubois on 30.03.24.
//

import Foundation

struct OpenAPIExternalDocumentation : 
    ThrowingHashMapInitiable {
    init(_ map: [AnyHashable : Any]) throws {
        url = try map.tryRead("url", String.self, root: "externalDocumentation")
        self.description = map.readIfPresent("description", String.self)
    }
    var description : String? = nil
    var url : String
    
}
