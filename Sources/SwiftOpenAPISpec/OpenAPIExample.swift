//
//  File.swift
//  
//
//  Created by Patric Dubois on 27.03.24.
//

import Foundation
import Foundation
public struct OpenAPIExample : KeyedElement, PointerNavigable {
    public static let SUMMARY_KEY = "summary"
    public static let DESCRIPTION_KEY = "description"
    public static let VALUE_KEY = "value"
    public static let REF_KEY = "$ref"
    public static let EXTERNAL_VALUE_KEY = "externalValue"
    public init(_ map: [String : Any]) throws {
        self.summary = map.readIfPresent(Self.SUMMARY_KEY, String.self)
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
        self.value = map[Self.VALUE_KEY]
        self.externalValue = map.readIfPresent(Self.EXTERNAL_VALUE_KEY, String.self)
        self.ref = map.readIfPresent(Self.REF_KEY, String.self)
    }
    public func element(for segmentName: String) throws -> Any? {
        try Self.element(for: segmentName)
    }
    public var key : String?
    public var summary : String? = nil
    public var description : String? = nil
    public var value : Any? = nil
    public var externalValue : String? = nil
    public var ref : String? = nil
    public var userInfos =  [OpenAPIObject.UserInfo]()
   
}
