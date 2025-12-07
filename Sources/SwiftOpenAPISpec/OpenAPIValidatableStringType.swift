//
//  OpenAPIIntegerType.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 07.12.25.
//


public struct OpenAPIValidatableStringType :  OpenAPIValidatableSchemaType, ThrowingHashMapInitiable  {
    
    
    public static let TYPE_KEY = "type"
    public static let ALLOWED_ELEMENTS_KEY = "enum"
    
    public init(_ map: [AnyHashable : Any]) throws {
        self.type = map[Self.TYPE_KEY] as? String
        self.allowedElements = map[Self.ALLOWED_ELEMENTS_KEY] as? [String]
    }
   
    public func validate() throws {
        
    }
    public let type : String?
    public let allowedElements : [String]?
}
