//
//  SchemaConversionError.swift
//  openapigenerator
//
//  Created by Patric Dubois on 19.12.25.
//



/// Errors thrown by ``SchemaConverter``
public enum SchemaConversionError: Error {
    case unsupportedKeyword(String)
    case nonJSONMediaType
    case noSchemaForReference(String)
    case noSchemaForReferenceInAllOf(String)
    case noSchemaForReferenceInAllOfWithDiscriminator(String)
    case noSchemaForReferenceInAllOfWithDiscriminatorAndNoDiscriminatorValue(String)
    case noSchemaForReferenceInOneOf(String)
}


