//
//  File.swift
//  
//
//  Created by Patric Dubois on 29.03.24.
//

import Foundation
struct OpenAPIRequestBody : ThrowingHashMapInitiable {
    static let DESCRIPTION_KEY = "description"
    static let REQUIRED_KEY = "required"
    static let CONTENTS_KEY = "content"
    init(_ map: [AnyHashable : Any]) throws {
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
        self.required = map.readIfPresent(Self.REQUIRED_KEY, Bool.self) ?? false
        if let contentsMap = map[Self.CONTENTS_KEY] as? [AnyHashable : Any]{
            self.contents = try MapListMap.map(contentsMap )
        }
        
    }
    var description : String? = nil
    var required : Bool = false
    var contents : [OpenAPIMediaType] = []
   
    
}
