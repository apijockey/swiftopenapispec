//
//  OpenAPIDefaultSchemaType.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 07.12.25.
//


public struct OpenAPIDefaultSchemaType : OpenAPIValidatableSchemaType {
    public static let TYPE_KEY = "type"
    public init(_ map: [AnyHashable : Any]) throws {
        self.type = map[Self.TYPE_KEY] as? String
    }
    
    public func validate() throws {
        
    }
    public static func validatableType(_ string : String)  -> OpenAPIValidatableSchemaType.Type? {
        switch string {
            case "integer" : return OpenAPIValidatableIntegerType.self
            case "string" : return OpenAPIValidatableStringType.self
            case "object" : return OpenAPIValidatableObjectType.self
            default:
                return nil
        }
    }
    public let type : String?
}
