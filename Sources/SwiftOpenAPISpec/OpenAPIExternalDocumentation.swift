//
//  File.swift
//  
//
//  Created by Patric Dubois on 30.03.24.
//

import Foundation

public struct OpenAPIExternalDocumentation :
    ThrowingHashMapInitiable {
    public init(_ map: [AnyHashable : Any]) throws {
        url = try map.tryRead("url", String.self, root: "externalDocumentation")
        self.description = map.readIfPresent("description", String.self)
    }
    public var description : String? = nil
    public var url : String
    
}
