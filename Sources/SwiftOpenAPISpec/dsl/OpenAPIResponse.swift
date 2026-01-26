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
public struct OpenAPIResponse : KeyedElement, PointerNavigable {
    public static let DESCRIPTION_KEY = "description"
    public static let SUMMARY_KEY = "summary"
    public static let CONTENT_KEY = "content"
    public static let HEADERS_KEY = "headers"
    public static let LINKS_KEY = "links"
    public init(load map: StringDictionary) throws {
        if let ref  =  try OpenAPISchemaReference.initReference(from: (map)) {
            self.ref = ref
            return
        }
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, valueType:  String.self)
        self.summary = map.readIfPresent(Self.SUMMARY_KEY, valueType: String.self)
        self.content = try map.mapListIfPresent(Self.CONTENT_KEY, objectType: OpenAPIMediaType.self)
        self.headers = try map.mapListIfPresent(Self.HEADERS_KEY, objectType: OpenAPIHeader.self)
        self.links =   try map.mapListIfPresent(Self.LINKS_KEY, objectType: OpenAPILink .self)
      
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
   
    
    public func element(for segmentName : String) throws -> NavigationResult{
        switch segmentName {
        case Self.CONTENT_KEY: return try content.element(for: segmentName)
        case Self.DESCRIPTION_KEY : return .value(JSONValue(description))
        case Self.HEADERS_KEY: return try self.headers.element(for: segmentName)
        case Self.LINKS_KEY: return try self.links.element(for: segmentName)
             
        case Self.SUMMARY_KEY: return .value(JSONValue(self.summary))
        case OpenAPISchemaReference.REF_KEY: return .reference(ref?.reference)
        default : throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIResponse", segmentName)
        }
    }
}


extension Array where Element : KeyedElement, Element : PointerNavigable {
    public func element(for segmentName : String) throws -> NavigationResult{
        guard let element = self.first (where:{ element in
            element.key == segmentName
        }) else {
            return .notFound(segmentName)
        }
        return .navigable(element)
    }
}
