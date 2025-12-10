//
//  OpenAPIDefaultSchemaType 2.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 07.12.25.
//


public struct OpenAPIValidatableOneOfType : OpenAPIValidatableSchemaType {
    public static let TYPE_KEY = "oneOf"
    public init(_ map: [String : Any]) throws {
        self.type = map[Self.TYPE_KEY] as? String
        guard let list = (map["oneOf"] as? [Any]) else {
            return
        }
        self.items = try list.asValidatableSchemaType()
        
        
    }
    
    public func validate() throws {
        
    }
    public let type : String?
    public var items: [OpenAPIValidatableSchemaType]?
    public var userInfos =  [OpenAPIObject.UserInfo]()
}
