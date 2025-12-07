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
        if let type = map[Self.TYPE_KEY] as? String,
            let validatableType = OpenAPIDefaultSchemaType.validatableType(type) {
            self.type = try validatableType.init(map)
        }
        format = map.readIfPresent(Self.FORMAT_KEY, String.self)
    }
    public  var key : String? = nil
    public var type : OpenAPIValidatableSchemaType?
    public  var format : String? = nil
}

