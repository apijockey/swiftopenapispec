//
//  OpenAPIIntegerType.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 07.12.25.
//


public struct OpenAPIValidatableDoubleType :  OpenAPIValidatableSchemaType, ThrowingHashMapInitiable  {
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
        self.defaultValue = map[Self.DEFAULT_KEY] as? Double
        self.multipleOf =  map[Self.MULTIPLEOF_KEY] as? Double
        self.maximum =  map[Self.MAXIMUM_KEY]  as? Double
        self.exclusiveMaximum =  map[Self.EXCLUSIVEMAXIMUM_KEY]  as? Double
        self.minimum =  map[Self.MINIMUM_KEY]  as? Double
        self.exclusiveMinimum =  map[Self.EXCLUSIVEMINIMUM_KEY]  as? Double
    }
    public let type : String?
    public let multipleOf : Double?
    public let defaultValue : Double?
    public let maximum : Double?
    public let exclusiveMaximum :Double?
    public let minimum : Double?
    public let exclusiveMinimum : Double?
    public var userInfos =  [OpenAPISpec.UserInfo]()
    
}
