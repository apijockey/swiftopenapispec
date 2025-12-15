//
//  OpenAPIDefaultSchemaType 2.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 07.12.25.
//


public struct OpenAPIObjectType : OpenAPIValidatableSchemaType, PointerNavigable{
    public func element(for segmentName: String) throws -> Any? {
        switch segmentName {
        case Self.DEPENDENT_REQUIRED_KEY : return self.dependentRequired
        case Self.MIN_PROPERTIES_KEY : return self.minProperties
        case Self.MAX_PROPERTIES_KEY : return self.maxProperties
        case Self .TYPE_KEY: return self.type
        case Self.UNEVALUATEDPROPERTIES_KEY : return self.unevaluatedProperties
        case Self .PROPERTIES_KEY: return self.properties
        case Self .REQUIRED_KEY: return self.required
        default:
            if let prop = self.properties[key: segmentName] {
                return prop
            }
            throw OpenAPIObject.Errors.unsupportedSegment("OpenAPIObjectType", segmentName)
            
        }
    }
    public static let DEPENDENT_REQUIRED_KEY = "dependentRequired"
    public static let TYPE_KEY = "type"
    public static let PROPERTIES_KEY = "properties"
    public static let MAX_PROPERTIES_KEY = "maxProperties"
    public static let MIN_PROPERTIES_KEY = "minProperties"
    public static let UNEVALUATEDPROPERTIES_KEY = "unevaluatedProperties"
    public static let REQUIRED_KEY = "required"
    public init(_ map: [String : Any]) throws {
        self.type = map[Self.TYPE_KEY] as? String
        if let propertiesMap = map[Self.PROPERTIES_KEY] as? StringDictionary{
            self.properties = try KeyedElementList.map(propertiesMap )
        }
        self.required = map[Self.REQUIRED_KEY] as? [String] ?? []
        self.minProperties = map.readIfPresent(Self.MIN_PROPERTIES_KEY, Int.self)
        self.maxProperties = map.readIfPresent(Self.MAX_PROPERTIES_KEY, Int.self)
        self.dependentRequired = map.readIfPresent(Self.DEPENDENT_REQUIRED_KEY, String.self)
    }
    
    public func validate() throws {
        
    }
    public var ref : String? // PointerNavigable
    public let type : String?
    public var dependentRequired : String?
    public var maxProperties : Int?
    public var minProperties : Int?
    public var properties : [OpenAPISchemaProperty] = []
    public var required : [String] = []
    public var unevaluatedProperties : Bool = false
    public var userInfos =  [OpenAPIObject.UserInfo]()
}
