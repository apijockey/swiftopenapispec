//
//  File.swift
//  
//
//  Created by Patric Dubois on 31.03.24.
//

import Foundation

struct OpenAPIKeyedExample : KeyedElement{
    static let SUMMARY_KEY = "summary"
    static let DESCRIPTION_KEY = "description"
    static let VALUE_KEY = "value"
    static let REF_KEY = "$ref"
    static let EXTERNAL_VALUE_KEY = "externalValue"
    init(_ map: [AnyHashable : Any]) throws {
        self.summary = map.readIfPresent(Self.SUMMARY_KEY, String.self)
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
        self.value = map.readIfPresent(Self.VALUE_KEY, String.self)
        if let anyValue = map[Self.VALUE_KEY] {
            self.value = anyValue
        }
        
        self.ref =  map.readIfPresent(Self.REF_KEY, String.self)
        self.externalValue = map.readIfPresent(Self.EXTERNAL_VALUE_KEY, String.self)
    }
    var key : String? = nil
    var summary : String? = nil
    var description : String? = nil
    var value : Any? = nil
    var externalValue : String? = nil
    var ref : String? = nil
   
}
