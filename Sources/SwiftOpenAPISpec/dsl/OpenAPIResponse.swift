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
    public init(load map: StringDictionary,_ diagnostics: inout [Diagnostic]) throws {
     
            self.ref =  try map.readIfPresent(OpenAPISchemaReference.REF_KEY, objectType: OpenAPISchemaReference.self)
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, valueType:  String.self)
        self.summary = map.readIfPresent(Self.SUMMARY_KEY, valueType: String.self)
        self.content = try map.mapListIfPresent(Self.CONTENT_KEY, objectType: OpenAPIMediaType.self)
        self.headers = try map.mapListIfPresent(Self.HEADERS_KEY, objectType: OpenAPIHeader.self)
        self.links =   try map.mapListIfPresent(Self.LINKS_KEY, objectType: OpenAPILink .self)
      
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
        case Self.CONTENT_KEY: return  .navigableCollection(self.content)
        case Self.DESCRIPTION_KEY : return .value(JSONValue(description))
        case Self.HEADERS_KEY: return .navigableCollection(self.headers)
        case Self.LINKS_KEY: return  .navigableCollection(self.links)
             
        case Self.SUMMARY_KEY: return .value(JSONValue(self.summary))
        case OpenAPISchemaReference.REF_KEY: return .reference(ref?.reference)
        default : throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIResponse", segmentName)
        }
    }
}


