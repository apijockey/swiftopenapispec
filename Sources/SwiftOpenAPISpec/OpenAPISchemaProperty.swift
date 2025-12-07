//
//  File.swift
//  
//
//  Created by Patric Dubois on 28.03.24.
//

import Foundation

public struct OpenAPISchemaProperty: KeyedElement {
    static let TYPE_KEY = "type"
    static let FORMAT_KEY = "format"
    public init(_ map: [AnyHashable : Any]) throws {
        type = map.readIfPresent(Self.TYPE_KEY, String.self)
        format = map.readIfPresent(Self.FORMAT_KEY, String.self)
    }
    public  var key : String? = nil
    public  var type : String? = nil
    public  var format : String? = nil
}

