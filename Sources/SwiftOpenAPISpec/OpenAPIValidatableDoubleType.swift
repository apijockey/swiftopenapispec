//
//  OpenAPIIntegerType.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 07.12.25.
//


public struct OpenAPIValidatableIntegerType :  OpenAPIValidatableSchemaType, ThrowingHashMapInitiable  {
    public func validate() throws {
        
    }
    public static let TYPE_KEY = "type"
    public static let DEFAULT_KEY = "default"
    public static let MULTIPLEOF_KEY = "multipleOf"
    public static let MINIMUM_KEY = "minimum"
    public static let MAXIMUM_KEY = "maximum"
    public static let EXCLUSIVEMINIMUM_KEY = "exclusiveMinimum"
    public static let EXCLUSIVEMAXIMUM_KEY = "exclusiveMaximum"
   
    public init(_ map: [AnyHashable : Any]) throws {
        self.type = map[Self.TYPE_KEY] as? String
        self.defaultValue = map[Self.DEFAULT_KEY] as? Int
        self.multipleOf =  map[Self.MULTIPLEOF_KEY] as? Int
        self.maximum =  map[Self.MAXIMUM_KEY]  as? Int
        self.exclusiveMaximum =  map[Self.EXCLUSIVEMAXIMUM_KEY]  as? Int
        self.minimum =  map[Self.MINIMUM_KEY]  as? Int
        self.exclusiveMinimum =  map[Self.EXCLUSIVEMINIMUM_KEY]  as? Int
    }
    public let type : String?
    public let multipleOf : Int?
    public let defaultValue : Int?
    public let maximum : Int?
    public let exclusiveMaximum : Int?
    public let minimum : Int?
    public let exclusiveMinimum : Int?
    public var userInfos =  [OpenAPISpec.UserInfo]()
    
}
