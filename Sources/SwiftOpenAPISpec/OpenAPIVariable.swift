//
//  File 3.swift
//  
//
//  Created by Patric Dubois on 30.03.24.
//

import Foundation

struct OpenAPIVariable : KeyedElement {
    static let ENUM_KEY = "enum"
    static let DEFAULT_KEY = "default"
    static let DESCRIPTION_KEY = "description"
    var key: String?
    
    init(_ map: [AnyHashable : Any]) throws {
        self.enumList = map.readIfPresent(Self.ENUM_KEY, [String].self)
        self.defaultValue = try map.tryRead(Self.DEFAULT_KEY, String.self,root: "variable")
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
            
    }
    var enumList : [String]? = nil
    var defaultValue : String
    var description : String? = nil
    
}
