//
//  Box.swift
//  openapigenerator
//
//  Created by Patric Dubois on 19.12.25.
//

/// gives indirection for the recursive definition of the ``OpenAPISchemaNode``
public final class Box<T> {
    var value: T
    init(_ value: T) { self.value = value }
}
