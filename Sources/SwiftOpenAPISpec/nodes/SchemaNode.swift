////
////  SchemaNode.swift
////  openapigenerator
////
////  Created by Patric Dubois on 19.12.25.
////
//
//
//
//public enum OpenAPISchemaNode {
//    
//    
//    case object(OpenAPIObjectType)
//    case array(OpenAPIArrayType)
//    case string(OpenAPIStringType)
//    case integer(OpenAPIIntegerType)
//    case number(OpenAPIDoubleType)
//    case ref(OpenAPISchemaReference)
//    case boolean
//    case null
//
//    // Komposition
//    case oneOf([OpenAPISchemaNode])
//    case anyOf([OpenAPISchemaNode])
//    case allOf([OpenAPISchemaNode])
//
//    case unsupported(reason: String)
//    static func initNode(_ type : any OpenAPIValidatableSchemaType)  -> OpenAPISchemaNode{
//        switch type as Any {
//        case let object as OpenAPIObjectType:
//            return .object(object)
//        case let array as OpenAPIArrayType:
//            return .array(array)
//        case let string as OpenAPIStringType:
//            return .string(string)
//        case let integer as OpenAPIIntegerType:
//            return .integer(integer)
//        case let number as OpenAPIDoubleType:
//            return .number(number)
//        case is OpenAPINullType:
//            return .null
//        case let reference as OpenAPISchemaReference:
//            return .ref(reference)
//        default:
//            return .unsupported(reason: "Unsupported Schema Type: \(Swift.type(of: type))")
//        }
//        
//    }
//}
