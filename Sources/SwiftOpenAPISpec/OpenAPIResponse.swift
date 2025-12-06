//
//  File.swift
//  
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation

struct OpenAPIResponse : KeyedElement{
    static let DESCRIPTION_KEY = "description"
    static let CONTENT_KEY = "content"
    static let LINKS_KEY = "links"
    init(_ map: [AnyHashable : Any]) throws {
        self.description = try map.tryRead(Self.DESCRIPTION_KEY, String.self, root:  "responses")
        if let contentMap = map.readIfPresent(Self.CONTENT_KEY, [AnyHashable:Any] .self) {
            self.content = try MapListMap<OpenAPIMediaType>.map(contentMap)
        }
        if let linkMap = map.readIfPresent(Self.LINKS_KEY, [AnyHashable:Any] .self) {
            self.links = try MapListMap<OpenAPILink>.map(linkMap)
        }
    }
    var description : String
    var content: [OpenAPIMediaType] = []
    var links : [OpenAPILink] =   []
    var key : String? = nil
}

