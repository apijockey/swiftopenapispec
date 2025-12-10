//
//  File.swift
//  
//
//  Created by Patric Dubois on 27.03.24.
//

import Foundation
import Foundation
public struct OpenAPIExample : ThrowingHashMapInitiable{
    public static let SUMMARY_KEY = "summary"
    public static let DESCRIPTION_KEY = "description"
    public static let VALUE_KEY = "value"
    public static let REF_KEY = "value"
    public static let EXTERNAL_VALUE_KEY = "externalValue"
    public init(_ map: [AnyHashable : Any]) throws {
        self.summary = map.readIfPresent(Self.SUMMARY_KEY, String.self)
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
        self.value = map.readIfPresent(Self.VALUE_KEY, String.self)
        self.externalValue = map.readIfPresent(Self.EXTERNAL_VALUE_KEY, String.self)
        self.ref = try map.mapIfPresent(Self.REF_KEY, OpenAPISchemaReference.self)
    }
    public var summary : String? = nil
    public var description : String? = nil
    public var value : String? = nil
    public var externalValue : String? = nil
    public var ref : OpenAPISchemaReference? = nil
    public var userInfos =  [OpenAPISpec.UserInfo]()
   
}
