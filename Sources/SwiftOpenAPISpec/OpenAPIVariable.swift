//
//  File 3.swift
//  
//
//  Created by Patric Dubois on 30.03.24.
//

import Foundation

public struct OpenAPIVariable : KeyedElement {
    public static let ENUM_KEY = "enum"
    public static let DEFAULT_KEY = "default"
    public static let DESCRIPTION_KEY = "description"
    public var key: String?
    
    public init(_ map: [String : Any]) throws {
        self.enumList = map.readIfPresent(Self.ENUM_KEY, [String].self)
        self.defaultValue = try map.tryRead(Self.DEFAULT_KEY, String.self,root: "variable")
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
            
    }
    public var enumList : [String]? = nil
    public var defaultValue : String
    public var description : String? = nil
    public var userInfos =  [OpenAPIObject.UserInfo]()
    
}
