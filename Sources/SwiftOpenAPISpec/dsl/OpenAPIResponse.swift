/*
 * Copyright 2025 CgSe Computergrafik und Softwareentwicklung GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
//  Created by Patric Dubois on 26.03.24.
//

import Foundation


/// An OpenAPIResponse is a child of ``OpenAPIOperation`` and can be identified by its unique ``key``, being an HTTP status, like '200'
public struct OpenAPIResponse : KeyedElement, PointerNavigable,OpenAPISchemaReferenceable {
    public static let DESCRIPTION_KEY = "description"
    public static let SUMMARY_KEY = "summary"
    public static let CONTENT_KEY = "content"
    public static let HEADERS_KEY = "headers"
    public static let LINKS_KEY = "links"
    public init(load map: [String : Any]) throws {
        if let ref  =  try OpenAPISchemaReference.initReference(from: (map)) {
            self.ref = ref
            return
        }
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
        self.summary = map.readIfPresent(Self.SUMMARY_KEY, String.self)
        if let contentMap = map.readIfPresent(Self.CONTENT_KEY, StringDictionary .self) {
            self.content = try KeyedElementList<OpenAPIMediaType>.map(contentMap).value
        }
         if let headerMap = map.readIfPresent(Self.HEADERS_KEY, StringDictionary .self) {
             self.headers = try KeyedElementList<OpenAPIHeader>.map(headerMap).value
         }
        if let linkMap = map.readIfPresent(Self.LINKS_KEY, StringDictionary .self) {
            self.links = try KeyedElementList<OpenAPILink>.map(linkMap).value
        }
      
      
      
    }
    public static func initialize(_ map: StringDictionary) throws ->  InitializationResult<Self> {
           let element = try Self(load: map)
           return InitializationResult(value: element, diagnostics: [])
       }

    public var summary : String?
    public var description : String?
    public var content: [OpenAPIMediaType] = []
    public var headers: [OpenAPIHeader] = []
    public var links : [OpenAPILink] =   []
    public var key : String? = nil
    public var ref : OpenAPISchemaReference? = nil
   
    
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

