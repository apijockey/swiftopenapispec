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
public struct OpenAPIInfo : KeyedElement, PointerNavigable {
  
    
    
    
    static let CONTACT_KEY = "contact"
    static let DESCRIPTION_KEY = "description"
    static let LICENSE_KEY = "license"
    static let SUMMARY_KEY = "summary"
    static let TERMS_KEY = "termsOfService"
    static let TITLE_KEY = "title"
    static let VERSION_KEY = "version"
    public init(load map: StringDictionary) throws {
        self.version = map.readIfPresent(Self.VERSION_KEY, valueType: String.self)
        self.title = map.readIfPresent(Self.TITLE_KEY,valueType: String.self)
        self.summary = map.readIfPresent(Self.SUMMARY_KEY,valueType: String.self)
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY,valueType: String.self)
        self.termsOfService = map.readIfPresent( Self.TERMS_KEY,valueType: String.self)
        self.contact = try  map.readIfPresent(Self.CONTACT_KEY, objectType: OpenAPIContact.self)
        self.license = try map.readIfPresent(Self.LICENSE_KEY, objectType: OpenAPILicense.self)
        extensions = try OpenAPIExtension.extensionElements(map)
        
    }
    public static func initialize(_ map: StringDictionary) throws ->  InitializationResult<Self> {
           let element = try Self(load: map)
           return InitializationResult(value: element, diagnostics: [])
       }

    public func element(for segmentName: String) throws -> NavigationResult {
        switch segmentName {
        case Self.CONTACT_KEY: return .navigable(contact)
        case Self.DESCRIPTION_KEY: return.value(JSONValue(description))
        case Self.LICENSE_KEY: return .navigable(license)
        case Self.TERMS_KEY: return .value(JSONValue(termsOfService))
        case Self.TITLE_KEY: return .value(JSONValue(title))
        case Self.VERSION_KEY: return .value(JSONValue(version))
        case Self.SUMMARY_KEY: return .value(JSONValue(summary))
    case Self.TERMS_KEY: return .value(JSONValue(termsOfService))
        case Self.CONTACT_KEY: return .navigable(contact)
        
        
        default:
            // Für x-* Vendor Extensions einzelne Keys erlauben: "x-..." -> passenden Extension-Wert liefern
            if segmentName.hasPrefix("x-"), let exts = extensions {
                if let ext = exts.first(where: { $0.key == segmentName }) {
                    // Gib die strukturierte oder einfache Extension zurück
                    return .value(JSONValue(ext.structuredExtension?.properties ?? ext.simpleExtensionValue))
                }
            }
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIInfo", segmentName)
        }
    }
    public var contact : OpenAPIContact? = nil
    public var description : String? = nil
    public var extensions : [OpenAPIExtension]?
    public var license : OpenAPILicense? = nil
    public var termsOfService : String? = nil
    public var title : String?
    public var  summary : String?
    public var ref: OpenAPISchemaReference? { nil}
    public var key: String?
   
    public var version : String?
    
}
