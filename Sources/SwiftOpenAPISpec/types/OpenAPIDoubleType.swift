//
//  OpenAPIIntegerType.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 07.12.25.
//


public struct OpenAPIDoubleType :  OpenAPIValidatableSchemaType, ThrowingHashMapInitiable, PointerNavigable  {
    public func element(for segmentName: String) throws -> Any? {
        switch segmentName {
        case Self.FORMAT_KEY : return format
        case Self.TYPE_KEY : return type
        case Self.DEFAULT_KEY :return defaultValue
        case Self.MULTIPLEOF_KEY :return multipleOf
        case Self.MINIMUM_KEY: return minimum
        case Self.MAXIMUM_KEY :return maximum
        case Self.EXCLUSIVEMINIMUM_KEY : return exclusiveMinimum
        case Self.EXCLUSIVEMAXIMUM_KEY : return exclusiveMaximum
        default:
                    throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIDoubleType", segmentName)
        }
    }
    
  
    
    public func validate() throws {
        
    }
    public static let FORMAT_KEY : String = "format"
    public static let TYPE_KEY = "type"
    public static let DEFAULT_KEY = "default"
    public static let MULTIPLEOF_KEY = "multipleOf"
    public static let MINIMUM_KEY = "minimum"
    public static let MAXIMUM_KEY = "maximum"
    public static let EXCLUSIVEMINIMUM_KEY = "exclusiveMinimum"
    public static let EXCLUSIVEMAXIMUM_KEY = "exclusiveMaximum"
   
    public init(_ map: [String : Any]) throws {
        self.type = map[Self.TYPE_KEY] as? String
        self.defaultValue = map[Self.DEFAULT_KEY] as? Double
        self.multipleOf =  map[Self.MULTIPLEOF_KEY] as? Double
        self.maximum =  map[Self.MAXIMUM_KEY]  as? Double
        self.exclusiveMaximum =  map[Self.EXCLUSIVEMAXIMUM_KEY]  as? Double
        self.minimum =  map[Self.MINIMUM_KEY]  as? Double
        self.exclusiveMinimum =  map[Self.EXCLUSIVEMINIMUM_KEY]  as? Double
    }
    public let type : String?
    public var format : String?
    public let multipleOf : Double?
    public let defaultValue : Double?
    public let maximum : Double?
    public let exclusiveMaximum :Double?
    public let minimum : Double?
    public let exclusiveMinimum : Double?
    public var userInfos =  [OpenAPISpecification.UserInfo]()
    public var ref: OpenAPISchemaReference? { nil}
    
}
