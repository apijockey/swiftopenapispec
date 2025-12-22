//
//  File.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation
public struct OpenAPIContact : ThrowingHashMapInitiable , PointerNavigable {
    public func element(for segmentName: String) throws -> Any? {
        switch segmentName {
        case Self.EMAIL_KEY: return email
        case Self.NAME_KEY: return name
        case Self.URL_KEY: return url
        default: throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIContact", segmentName)
        }
    }
    
   
    public static let EMAIL_KEY = "email"
    public  static let NAME_KEY = "name"
    public static let URL_KEY = "url"
   
    public init(_ map : StringDictionary) throws {
        if let name = map[Self.NAME_KEY] as? String {
            self.name = name
        }
        if let url = map[Self.URL_KEY] as? String {
            self.url = url
        }
        if let email = map[Self.EMAIL_KEY] as? String {
            self.email = email
        }
        extensions = try OpenAPIExtension.extensionElements(map)
    }
    public var email : String? = nil
    public var extensions : [OpenAPIExtension]?
    public  var name : String? = nil
    public var url : String? = nil
    
    public var ref: OpenAPISchemaReference? { nil}
}
