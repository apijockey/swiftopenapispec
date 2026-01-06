//
//  SchemaNode.swift
//  openapigenerator
//
//  Created by Patric Dubois on 19.12.25.
//



public enum OpenAPISchemaNode {
    
    
    case object(OpenAPIObjectType)
    case array(OpenAPIArrayType)
    case string(OpenAPIStringType)
    case integer(OpenAPIIntegerType)
    case number(OpenAPIDoubleType)
    case boolean
    case null

    // Komposition
    case oneOf([any OpenAPIValidatableSchemaType])
    case anyOf([any OpenAPIValidatableSchemaType])
    case allOf([any OpenAPIValidatableSchemaType])

    // Notfalls: wenn du was nicht unterstützt, aber Import nicht abbrechen willst
    case unsupported(reason: String)
}
