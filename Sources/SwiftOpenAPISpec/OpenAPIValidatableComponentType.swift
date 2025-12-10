//
//  OpenAPIIntegerType.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 07.12.25.
//


public struct OpenAPIValidatableStringType :  OpenAPIValidatableSchemaType, ThrowingHashMapInitiable  {
    
    
    public static let MAXLENGTH_KEY = "maxLength"
    public static let MINLENGTH_KEY = "minLength"
    public static let PATTERN_KEY = "pattern"
    public static let TYPE_KEY = "type"
    public static let ALLOWED_ELEMENTS_KEY = "enum"
    
    public init(_ map: [AnyHashable : Any]) throws {
        self.type = map[Self.TYPE_KEY] as? String
        if let allowedElements = map[Self.ALLOWED_ELEMENTS_KEY] as? [String] {
            self.allowedElements = Set(allowedElements)
        } else {
            self.allowedElements = nil
        }
        self.maxLength = map[Self.MAXLENGTH_KEY] as? Int
        self.minLength = map[Self.MINLENGTH_KEY] as? Int
        self.pattern = map[Self.PATTERN_KEY] as? String
    }
   
    public func validate() throws {
        
    }
    public let type : String?
    public let allowedElements : Set<String>?
    public let maxLength: Int?
    public let minLength: Int?
    public let pattern: String?
    public var userInfos =  [OpenAPIObject.UserInfo]()
}
