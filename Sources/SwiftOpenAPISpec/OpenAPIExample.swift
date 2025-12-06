//
//  File.swift
//  
//
//  Created by Patric Dubois on 27.03.24.
//

import Foundation
import Foundation
struct OpenAPIExample : ThrowingHashMapInitiable{
    static let SUMMARY_KEY = "summary"
    static let DESCRIPTION_KEY = "description"
    static let VALUE_KEY = "value"
    static let REF_KEY = "value"
    static let EXTERNAL_VALUE_KEY = "externalValue"
    init(_ map: [AnyHashable : Any]) throws {
        self.summary = map.readIfPresent(Self.SUMMARY_KEY, String.self)
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
        self.value = map.readIfPresent(Self.VALUE_KEY, String.self)
        self.externalValue = map.readIfPresent(Self.EXTERNAL_VALUE_KEY, String.self)
        self.ref = try map.mapIfPresent(Self.REF_KEY, OpenAPISchemaReference.self)
    }
    var summary : String? = nil
    var description : String? = nil
    var value : String? = nil
    var externalValue : String? = nil
    var ref : OpenAPISchemaReference? = nil
   
}
