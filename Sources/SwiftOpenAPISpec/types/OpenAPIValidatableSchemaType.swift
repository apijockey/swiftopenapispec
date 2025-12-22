//
//  OpenAPIValidatableSchemaTypes.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 07.12.25.
//


public protocol OpenAPIValidatableSchemaType: ThrowingHashMapInitiable, Equatable {
    func validate() throws
    /// Polymorpher Vergleich, um Existentials (any OpenAPIValidatableSchemaType) sicher vergleichen zu können.
    /// Standard-Implementierung castet auf Self und nutzt dann Equatable.
    func isEqual(to other: any OpenAPIValidatableSchemaType) -> Bool
}

public extension OpenAPIValidatableSchemaType {
    func isEqual(to other: any OpenAPIValidatableSchemaType) -> Bool {
        guard let otherSame = other as? Self else { return false }
        return self == otherSame
    }
}
