//
//  OpenAPIDefaultSchemaType.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 07.12.25.
//


public struct OpenAPIDefaultSchemaType : OpenAPIValidatableSchemaType {
    public static let TYPE_KEY = "type"
    public init(_ map: [String : Any]) throws {
        self.type = map[Self.TYPE_KEY] as? String
    }
    
    public func validate() throws {
        
    }
    public static func validatableType(_ string : String)  -> OpenAPIValidatableSchemaType.Type? {
        switch string {
            case "array" : return OpenAPIValidatableArrayType.self
            case "integer" : return OpenAPIValidatableIntegerType.self
            case "number" : return OpenAPIValidatableDoubleType.self
            case "string" : return OpenAPIValidatableStringType.self
            case "object" : return OpenAPIValidatableObjectType.self
            case "$ref" : return OpenAPIValidatableComponentType.self
           
            default:
                return nil
        }
    }
    public let type : String?
    public var userInfos =  [OpenAPIObject.UserInfo]()
}
public extension Array where Element == OpenAPIDefaultSchemaType   {
    init(_ map: [AnyHashable : Any]) throws {
        self.init()
       print(map)
    }
}

public extension Array where Element == Any   {
    func asValidatableSchemaType() throws -> [OpenAPIValidatableSchemaType] {
        var map : [OpenAPIValidatableSchemaType] = []
            for element in self {
                if let dict = element as? [String : Any],
                   let firstKey = dict.keys.first,
                   let type = OpenAPIDefaultSchemaType.validatableType(firstKey)             {
                    let element = try type.init(dict)
                    map.append(element)
                }
                else  if let dict = element as? [String : Any],
                    let type = dict[OpenAPIDefaultSchemaType.TYPE_KEY] as? String,
                        let typeInfo = OpenAPIDefaultSchemaType.validatableType(type) {
                        let validatableType = try typeInfo.init(dict)
                        map.append(validatableType)
                }
        }
        return map
    }
}
