//
//  OpenAPIDefaultSchemaType 2.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 07.12.25.
//


public struct OpenAPIValidatableObjectType : OpenAPIValidatableSchemaType {
    public static let TYPE_KEY = "type"
    public static let PROPERTIES_KEY = "properties"
    public static let UNEVALUATEDPROPERTIES_KEY = "unevaluatedProperties"
    public static let REQUIRED_KEY = "required"
    public init(_ map: [AnyHashable : Any]) throws {
        self.type = map[Self.TYPE_KEY] as? String
        if let propertiesMap = map[Self.PROPERTIES_KEY] as? [AnyHashable:Any]{
            self.properties = try MapListMap.map(propertiesMap )
        }
        self.required = map[Self.REQUIRED_KEY] as? [String] ?? []
    }
    
    public func validate() throws {
        
    }
    public let type : String?
    public var maxProperties : Int?
    public var minProperties : Int?
    public var properties : [OpenAPISchemaProperty] = []
    public var dependentRequired : String?
    public var unevaluatedProperties : Bool = false
    public var required : [String] = []
    public var userInfos =  [OpenAPIObject.UserInfo]()
}
