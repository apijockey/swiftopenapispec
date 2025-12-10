//
//  OpenAPIIntegerType.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 07.12.25.
//


public struct OpenAPIValidatableComponentType :  OpenAPIValidatableSchemaType, ThrowingHashMapInitiable  {
    
    
  
    public static let REF_KEY = "$ref"
    public init(_ map: [String : Any]) throws {
        self.ref = map[Self.REF_KEY] as? String
        
        
    }
    public func validate() throws {
        
    }
    public let ref : String?
    public var userInfos =  [OpenAPIObject.UserInfo]()
     
}
