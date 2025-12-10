//
//  File.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation


/// An OpenAPIResponse is a child of ``OpenAPIOperation`` and can be identified by its unique ``key``, being an HTTP status, like '200'
public struct OpenAPIResponse : KeyedElement{
    public static let DESCRIPTION_KEY = "description"
    public static let CONTENT_KEY = "content"
    public static let LINKS_KEY = "links"
    public init(_ map: [String : Any]) throws {
        self.description = try map.tryRead(Self.DESCRIPTION_KEY, String.self, root:  "responses")
        if let contentMap = map.readIfPresent(Self.CONTENT_KEY, StringDictionary .self) {
            self.content = try KeyedElementList<OpenAPIMediaType>.map(contentMap)
        }
        if let linkMap = map.readIfPresent(Self.LINKS_KEY, StringDictionary .self) {
            self.links = try KeyedElementList<OpenAPILink>.map(linkMap)
        }
    }
    public var description : String
    public var content: [OpenAPIMediaType] = []
    public var links : [OpenAPILink] =   []
    public var key : String? = nil
    public var userInfos =  [OpenAPIObject.UserInfo]()
}

public extension Array where Element == OpenAPIResponse  {
    
    subscript (httpstatus key: String) -> OpenAPIResponse? {
        return first { response in
            response.key == key
        }
    }
    
}
