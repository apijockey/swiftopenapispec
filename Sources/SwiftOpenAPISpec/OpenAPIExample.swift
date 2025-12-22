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
 
    public static let EXTERNAL_VALUE_KEY = "externalValue"
    public static let SERIALIZED_VALUE_KEY = "serializedValue"
    public init(_ map: [String : Any]) throws {
        self.summary = map.readIfPresent(Self.SUMMARY_KEY, String.self)
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
        self.value = map[Self.VALUE_KEY]
        self.externalValue = map.readIfPresent(Self.EXTERNAL_VALUE_KEY, String.self)
       
        if let refMap = map[OpenAPISchemaReference.REF_KEY] as? StringDictionary {
                    self.ref = try OpenAPISchemaReference(refMap)
        }
        if let ref = map[OpenAPISchemaReference.REF_KEY] as? String {
                    self.ref =  OpenAPISchemaReference(ref: ref)
        }
        self.serializedValue = map.readIfPresent(Self.SERIALIZED_VALUE_KEY, String.self)
    }
    public func element(for segmentName: String) throws -> Any? {
        switch segmentName {
        case Self.SUMMARY_KEY: return self.summary
        case Self.DESCRIPTION_KEY: return self.description
        case Self.VALUE_KEY: return self.value
            case Self.EXTERNAL_VALUE_KEY: return self.externalValue
        case OpenAPISchemaReference.REF_KEY: return self.ref
        default:
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIExample", segmentName)
        }
    }
    public var key : String?
    public var summary : String? = nil
    public var description : String? = nil
    public var value : Any? = nil
    public var dataValue : Any? = nil
    public var serializedValue : String? = nil
    public var externalValue : String? = nil
    public var ref : OpenAPISchemaReference? = nil
  
   
}
