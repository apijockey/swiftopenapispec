//
//  File.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation


/// An OpenAPIResponse is a child of ``OpenAPIOperation`` and can be identified by its unique ``key``, being an HTTP status, like '200'
public struct OpenAPIResponse : KeyedElement, PointerNavigable {
    public static let DESCRIPTION_KEY = "description"
    public static let SUMMARY_KEY = "summary"
    public static let CONTENT_KEY = "content"
    public static let HEADERS_KEY = "headers"
    public static let LINKS_KEY = "links"
    public init(_ map: [String : Any]) throws {
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
        self.summary = map.readIfPresent(Self.SUMMARY_KEY, String.self)
        if let contentMap = map.readIfPresent(Self.CONTENT_KEY, StringDictionary .self) {
            self.content = try KeyedElementList<OpenAPIMediaType>.map(contentMap)
        }
         if let headerMap = map.readIfPresent(Self.HEADERS_KEY, StringDictionary .self) {
             self.headers = try KeyedElementList<OpenAPIHeader>.map(headerMap)
         }
        if let linkMap = map.readIfPresent(Self.LINKS_KEY, StringDictionary .self) {
            self.links = try KeyedElementList<OpenAPILink>.map(linkMap)
        }
        if let refMap = map[OpenAPISchemaReference.REF_KEY] as? StringDictionary {
            self.ref = try OpenAPISchemaReference(refMap)
        }
        if let ref = map[OpenAPISchemaReference.REF_KEY] as? String {
                    self.ref = OpenAPISchemaReference(ref: ref)
        }
    }
    public var summary : String?
    public var description : String?
    public var content: [OpenAPIMediaType] = []
    public var headers: [OpenAPIHeader] = []
    public var links : [OpenAPILink] =   []
    public var key : String? = nil
    public var ref : OpenAPISchemaReference? = nil
    public var userInfos =  [OpenAPISpecification.UserInfo]()
    
    public func element(for segmentName : String) throws -> Any? {
        switch segmentName {
        case Self.CONTENT_KEY: return self.content
        case Self.DESCRIPTION_KEY : return self.content
        case Self.HEADERS_KEY: return self.headers
        case Self.LINKS_KEY: return self.links
             
        case Self.SUMMARY_KEY: return self.summary
        case OpenAPISchemaReference.REF_KEY: return ref
            default : throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIResponse", segmentName)
        }
    }
}

