//
//  OpenAPIDefaultSchemaType 2.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 07.12.25.
//


public struct OpenAPIValidatableObjectType : OpenAPIValidatableSchemaType {
    public static let TYPE_KEY = "type"
    public init(_ map: [AnyHashable : Any]) throws {
        self.type = map[Self.TYPE_KEY] as? String
    }
    
    public func validate() throws {
        
    }
    public let type : String?
}
