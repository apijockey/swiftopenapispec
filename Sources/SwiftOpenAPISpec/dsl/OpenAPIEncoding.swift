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
public struct OpenAPIEncoding : KeyedElement, PointerNavigable {
   
    
    static let CONTENT_TYPE_KEY = "contentType"
    static let HEADERS_KEY = "headers"
    static let ENCODING_KEY = "encoding"
    static let PREFIX_ENCODING_KEY = "prefixEncoding"
    static let ITEM_ENCODING_KEY = "itemEncoding"
    static let EXTENSIONS_KEY = "extensions"
    public init(_ map: [String : Any]) throws {
        extensions = try OpenAPIExtension.extensionElements(map)
        self.contentType = map.readIfPresent(Self.CONTENT_TYPE_KEY, String.self)
        if let  subMap  = map[Self.HEADERS_KEY] as? StringDictionary {
            headers = try KeyedElementList<OpenAPIHeader>.map(subMap)
        }
        if let subMap = map[Self.ENCODING_KEY] as? StringDictionary {
            encoding = try KeyedElementList<OpenAPIEncoding>.map(subMap)
        }
        if let subMap = map[Self.PREFIX_ENCODING_KEY] as? StringDictionary {
            prefixEncoding = try KeyedElementList<OpenAPIEncoding>.map(subMap)
        }
        if let subMap = map[Self.PREFIX_ENCODING_KEY] as? StringDictionary {
            itemEncoding = try KeyedElementList<OpenAPIEncoding>.map(subMap)
        }
        
        
    }
    
    public func element(for segmentName: String) throws -> Any? {
        switch segmentName {
        case Self.CONTENT_TYPE_KEY: return contentType
        case Self.HEADERS_KEY: return headers
        case Self.ENCODING_KEY: return encoding
        case Self.PREFIX_ENCODING_KEY: return prefixEncoding
        case Self.ITEM_ENCODING_KEY: return itemEncoding
        case Self.EXTENSIONS_KEY: return extensions
        default:
            // Für x-* Vendor Extensions einzelne Keys erlauben: "x-..." -> passenden Extension-Wert liefern
            if segmentName.hasPrefix("x-"), let exts = extensions {
                if let ext = exts.first(where: { $0.key == segmentName }) {
                    // Gib die strukturierte oder einfache Extension zurück
                    return ext.structuredExtension?.properties ?? ext.simpleExtensionValue
                }
            }
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIEncoding", segmentName)
        }
    }
    public var contentType : String? = nil
    public var headers : [OpenAPIHeader]? = nil
    public var extensions : [OpenAPIExtension]?
    public var encoding :[OpenAPIEncoding]? = nil
    public var prefixEncoding :[OpenAPIEncoding]? = nil
    public var itemEncoding :[OpenAPIEncoding]? = nil
   
    public var key: String?
   
    public var ref : OpenAPISchemaReference? { nil}
    
}
