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
    static let STYLE_KEY = "style"
    static let EXPLODE_KEY = "explode"
    static let ALLOW_RESERVED_KEY = "allowReserved"
    static let HEADERS_KEY = "headers"
    static let ENCODING_KEY = "encoding"
    static let PREFIX_ENCODING_KEY = "prefixEncoding"
    static let ITEM_ENCODING_KEY = "itemEncoding"
    static let EXTENSIONS_KEY = "extensions"
    public init(load map: StringDictionary, diagnostics: inout [Diagnostic],pointer : String) throws {
        extensions = try OpenAPIExtension.extensionElements(map, &diagnostics,pointer: JSONPointer.join(pointer, "extensions"))
        self.contentType = map.readIfPresent(Self.CONTENT_TYPE_KEY, valueType: String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.CONTENT_TYPE_KEY))
        self.headers = try map.mapListIfPresent(Self.HEADERS_KEY, objectType: OpenAPIHeader.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.HEADERS_KEY))
        self.style = map.readIfPresent(Self.STYLE_KEY, valueType: String.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.STYLE_KEY))
        self.explode = map.readIfPresent(Self.EXPLODE_KEY, valueType: Bool.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.EXPLODE_KEY))
        self.allowReserved = map.readIfPresent(Self.ALLOW_RESERVED_KEY, valueType: Bool.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.EXPLODE_KEY))
        
        // Validate unsupported keys (excluding extensions as they are dynamic)
        var supportingElments = Set(Self.supportedKeys)
        supportingElments.formUnion((self.extensions).compactMap({ $0.key }))
      
        diagnostics.append(contentsOf: map.diagnoseUnsupportedElements(supportedKeys: supportingElments , pointer: pointer))
        
    }
    
    /// The set of keys supported by OpenAPI Encoding object (excluding dynamic extensions)
    private static var supportedKeys: Set<String> {
        [
            Self.CONTENT_TYPE_KEY,
            Self.HEADERS_KEY,
            Self.STYLE_KEY,
            Self.EXPLODE_KEY,
            OpenAPISchemaReference.REF_KEY,
            Self.ALLOW_RESERVED_KEY
        ]
    }
   
    public func element(for segmentName: String) throws -> NavigationResult {
        switch segmentName {
        case Self.CONTENT_TYPE_KEY: return .value(JSONValue(contentType))
        case Self.HEADERS_KEY: return .navigableCollection(headers)
        case Self.STYLE_KEY: return .value(JSONValue(string:self.style))
        case Self.EXPLODE_KEY : return .value(JSONValue(bool: self.explode))
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
    public var style : String? = nil
    public var explode : Bool? = nil
    public var allowReserved : Bool? = nil
    public var key: String?
   
    public var ref : OpenAPISchemaReference? { nil}
    
}
