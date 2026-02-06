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
    public init(load map: StringDictionary, diagnostics: inout [Diagnostic]) throws {
        extensions = try OpenAPIExtension.extensionElements(map, &diagnostics)
        self.contentType = map.readIfPresent(Self.CONTENT_TYPE_KEY, valueType: String.self)
        self.headers = try map.mapListIfPresent(Self.HEADERS_KEY, objectType: OpenAPIHeader.self, diagnostics: &diagnostics)
        self.encoding  = try map.mapListIfPresent(Self.ENCODING_KEY, objectType: OpenAPIEncoding.self, diagnostics: &diagnostics)
        self.prefixEncoding = try map.mapListIfPresent(Self.PREFIX_ENCODING_KEY,objectType: OpenAPIEncoding.self, diagnostics: &diagnostics)
        self.itemEncoding = try map.mapListIfPresent(Self.PREFIX_ENCODING_KEY,objectType: OpenAPIEncoding.self, diagnostics: &diagnostics)
        
    }
   
    public func element(for segmentName: String) throws -> NavigationResult {
        switch segmentName {
        case Self.CONTENT_TYPE_KEY: return .value(JSONValue(contentType))
        case Self.HEADERS_KEY: return .navigableCollection(headers)
        case Self.ENCODING_KEY: return .navigableCollection(encoding)
        case Self.PREFIX_ENCODING_KEY: return  .navigableCollection(prefixEncoding)
        case Self.ITEM_ENCODING_KEY: return .navigableCollection(itemEncoding)
        case Self.EXTENSIONS_KEY: return  .navigableCollection(extensions)
        default:
            // Für x-* Vendor Extensions einzelne Keys erlauben: "x-..." -> passenden Extension-Wert liefern
            if segmentName.hasPrefix("x-") {
                if let ext = extensions.first(where: { $0.key == segmentName }) {
                                              return .value(ext.value)
                                          }
            }
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIEncoding", segmentName)
        }
    }
    public var contentType : String? = nil
    public var headers : [OpenAPIHeader]  = []
    public var extensions : [OpenAPIExtension] = []
    public var encoding :[OpenAPIEncoding] = []
    public var prefixEncoding :[OpenAPIEncoding] = []
    public var itemEncoding :[OpenAPIEncoding] = []
   
    public var key: String?
   
    public var ref : OpenAPISchemaReference? { nil}
    
}
