//
//  OpenAPIDefaultSchemaType.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 07.12.25.
//


public struct OpenAPISchemaType : OpenAPIValidatableSchemaType {
    public static let TYPE_KEY = "type"
    public init(_ map: [String : Any]) throws {
        self.type = map[Self.TYPE_KEY] as? String
    }
    
    public func validate() throws {
        
    }
    public static func validatableType(_ string : String)  -> OpenAPIValidatableSchemaType.Type? {
        switch string {
            case "array" : return OpenAPIArrayType.self
            case "integer" : return OpenAPIIntegerType.self
            case "number" : return OpenAPIDoubleType.self
            case "string" : return OpenAPIStringType.self
            case "object" : return OpenAPIObjectType.self
            case "$ref" : return OpenAPIValidatableType.self
           
            default:
                return nil
        }
    }
    public let type : String?
    public var userInfos =  [OpenAPIObject.UserInfo]()
}
public extension Array where Element == OpenAPISchemaType   {
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
                   let type = OpenAPISchemaType.validatableType(firstKey)             {
                    let element = try type.init(dict)
                    map.append(element)
                }
                else  if let dict = element as? [String : Any],
                    let type = dict[OpenAPISchemaType.TYPE_KEY] as? String,
                        let typeInfo = OpenAPISchemaType.validatableType(type) {
                        let validatableType = try typeInfo.init(dict)
                        map.append(validatableType)
                }
        }
        return map
    }
}
