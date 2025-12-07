//
//  File 2.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation
//superset of https://datatracker.ietf.org/doc/html/draft-bhutton-json-schema-00
//https://spec.commonmark.org
//https://spec.openapis.org/oas/3.1/dialect/base
//https://json-schema.org
//https://datatracker.ietf.org/doc/html/draft-bhutton-json-schema-validation-00
// dialect:
//https://spec.openapis.org/oas/3.1/dialect/base
//
public struct NamedComponent<T> :  KeyedElement where T : ThrowingHashMapInitiable {
    public init(_ map: [AnyHashable : Any]) throws {
        type = try T(map)
    }
    public var key : String? = nil
    public var type : T? = nil
}

