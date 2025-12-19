//
//  File.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation
public struct OpenAPILicense : Codable , PointerNavigable {
    public func element(for segmentName: String) throws -> Any? {
        switch segmentName {
            case Self.NAME_KEY: return name
            case Self.IDENTIFIER_KEY: return identifier
            case Self.URL_KEY: return url
        default:
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPILicense", segmentName)
        }
    }
    
    public var ref: OpenAPISchemaReference? { nil}
    
    public static let NAME_KEY = "name"
    public static let IDENTIFIER_KEY = "identifier"
    public static let URL_KEY = "url"
    public init?(_ map : [String:Any?]) {
        guard let name = map[Self.NAME_KEY] as? String else {
            return nil
        }
        self.name = name
        if let text =  map[Self.IDENTIFIER_KEY] as? String {
            self.identifier = text
        }
        if let url = map[Self.URL_KEY] as? String {
            self.url = url
        }
        if let identifier = map[Self.URL_KEY] as? String {
            self.identifier = identifier
        }
    }
    public var name : String
    public var identifier : String? = nil
    public var url : String? = nil
}
