//
//  File.swift
//  
//
//  Created by Patric Dubois on 29.03.24.
//

import Foundation
// initally a special type to handle the ref element on an OpenaPISchema, now maybe more a base type for all elements, that can hold a ref, meas, such an element must be included, where a ref can occur, try with OpenAPIExample
struct OpenAPISchemaReference  : ThrowingHashMapInitiable{
    static let REF_KEY = "$ref"
    init(_ map: [AnyHashable : Any]) throws {
        self.ref = map[Self.REF_KEY] as? String
    }
    var ref : String? = nil
}
