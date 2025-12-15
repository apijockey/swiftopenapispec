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
    }
    public var summary : String?
    public var description : String?
    public var content: [OpenAPIMediaType] = []
    public var headers: [OpenAPIHeader] = []
    public var links : [OpenAPILink] =   []
    public var key : String? = nil
    public var ref : String? // PointerNavigable
    public var userInfos =  [OpenAPIObject.UserInfo]()
    
    public func element(for segmentName : String) throws -> Any? {
        switch segmentName {
            case "content" : return self.content
            case "headers" : return self.headers
            case "links" : return self.links
            default : throw OpenAPIObject.Errors.unsupportedSegment("OpenAPIResponse", segmentName)
        }
    }
}

