//
//  File.swift
//  
//
//  Created by Patric Dubois on 28.03.24.
//

import Foundation

struct OpenAPISchemaProperty: KeyedElement {
    static let TYPE_KEY = "type"
    static let FORMAT_KEY = "format"
    init(_ map: [AnyHashable : Any]) throws {
        type = map.readIfPresent(Self.TYPE_KEY, String.self)
        format = map.readIfPresent(Self.FORMAT_KEY, String.self)
    }
    var key : String? = nil
    var type : String? = nil
    var format : String? = nil
}

