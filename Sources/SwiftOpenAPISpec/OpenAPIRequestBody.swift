//
//  File.swift
//  
//
//  Created by Patric Dubois on 29.03.24.
//

import Foundation
public struct OpenAPIRequestBody : ThrowingHashMapInitiable {
    public static let DESCRIPTION_KEY = "description"
    public static let REQUIRED_KEY = "required"
    public static let CONTENTS_KEY = "content"
    public init(_ map: [AnyHashable : Any]) throws {
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
        self.required = map.readIfPresent(Self.REQUIRED_KEY, Bool.self) ?? false
        if let contentsMap = map[Self.CONTENTS_KEY] as? [AnyHashable : Any]{
            self.contents = try MapListMap.map(contentsMap )
        }
        
    }
    public var description : String? = nil
    public var required : Bool = false
    public var contents : [OpenAPIMediaType] = []
   
    
}
