//
//  File.swift
//  
//
//  Created by Patric Dubois on 30.03.24.
//

import Foundation

public struct OpenAPIExternalDocumentation :
    ThrowingHashMapInitiable, PointerNavigable {
    
    public static let URL_KEY = "url"
    public static let DESCRIPTION_KEY = "desccription"
    
    public func element(for segmentName: String) throws -> Any? {
        switch segmentName {
        case Self.URL_KEY: return url
        case Self.DESCRIPTION_KEY: return self.description
        default:
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIExternalDocumentation", segmentName)
        }
    }
    
  
    
    public init(_ map: [String : Any]) throws {
        url = try map.tryRead("url", String.self, root: "OpenAPIExternalDocumentation")
        self.description = map.readIfPresent("description", String.self)
    }
    public var description : String? = nil
    public var url : String
   
    public var ref: OpenAPISchemaReference? { nil}
    
}
