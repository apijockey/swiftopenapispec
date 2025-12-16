//
//  File.swift
//  
//
//  Created by Patric Dubois on 29.03.24.
//

import Foundation
// initally a special type to handle the ref element on an OpenaPISchema, now maybe more a base type for all elements, that can hold a ref, meas, such an element must be included, where a ref can occur, try with OpenAPIExample
public struct OpenAPISchemaReference  : ThrowingHashMapInitiable, PointerNavigable,  OpenAPIValidatableSchemaType{
    public func validate() throws {
        
    }
    
    public func element(for segmentName: String) throws -> Any? {
        if segmentName == Self.REF_KEY {
            return self
        }
        throw OpenAPIObject.Errors.unsupportedSegment("OpenAPISchemaReference", segmentName)
    }
    
    public static let REF_KEY = "$ref"
    public static let SUMMARY_KEY = "summary"
    public static let DESCRIPTION_KEY = "description"
    public init(_ map: [String : Any]) throws {
        self.reference = map.readIfPresent(Self.REF_KEY, String.self)
        self.summary = map.readIfPresent(Self.SUMMARY_KEY, String.self)
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
        if self.reference == nil {
            userInfos.append(OpenAPIObject.UserInfo(message: "ref ist mandatory", infoType: .error))
        }
    }
    public init(ref: String) {
        self.reference = ref
    }
    public var ref: OpenAPISchemaReference? { nil}
    public var reference : String? = nil
    public var summary : String? = nil
    public var description : String? = nil
    public var userInfos =  [OpenAPIObject.UserInfo]()
}
