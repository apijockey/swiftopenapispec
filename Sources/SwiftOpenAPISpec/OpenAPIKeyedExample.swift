//
//  File.swift
//  
//
//  Created by Patric Dubois on 31.03.24.
//

import Foundation

public struct OpenAPIKeyedExample : KeyedElement{
    public static let SUMMARY_KEY = "summary"
    public static let DESCRIPTION_KEY = "description"
    public static let VALUE_KEY = "value"
    public static let REF_KEY = "$ref"
    public static let EXTERNAL_VALUE_KEY = "externalValue"
    public init(_ map: [AnyHashable : Any]) throws {
        self.summary = map.readIfPresent(Self.SUMMARY_KEY, String.self)
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
        self.value = map.readIfPresent(Self.VALUE_KEY, String.self)
        if let anyValue = map[Self.VALUE_KEY] {
            self.value = anyValue
        }
        
        self.ref =  map.readIfPresent(Self.REF_KEY, String.self)
        self.externalValue = map.readIfPresent(Self.EXTERNAL_VALUE_KEY, String.self)
    }
    public var key : String? = nil
    public var summary : String? = nil
    public var description : String? = nil
    public var value : Any? = nil
    public var externalValue : String? = nil
    public var ref : String? = nil
    public var userInfos =  [OpenAPISpec.UserInfo]()
   
}
