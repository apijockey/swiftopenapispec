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
    public init(load map: [String : Any]) throws {
        self.version = map[Self.VERSION_KEY] as? String  ?? ""
        self.title = map[Self.TITLE_KEY] as? String
        if let text = map[Self.SUMMARY_KEY] as? String {
            self.summary = text
        }
        if let text = map[Self.DESCRIPTION_KEY] as? String {
            self.description = text
        }
        if let text = map[Self.TERMS_KEY] as? String {
            self.termsOfService = text
        }
        if let contactMap  =  map[Self.CONTACT_KEY] as? StringDictionary{
           let contact = try OpenAPIContact(load: contactMap)
            self.contact = contact
        }
        if let licenseMap  =  map[Self.LICENSE_KEY] as? StringDictionary,
           let license = OpenAPILicense(licenseMap) {
            self.license = license
        }
        extensions = try OpenAPIExtension.extensionElements(map)
        
    }
    public static func initialize(_ map: StringDictionary) throws ->  InitializationResult<Self> {
           let element = try Self(load: map)
           return InitializationResult(value: element, diagnostics: [])
       }

    public func element(for segmentName: String) throws -> Any? {
        switch segmentName {
        case Self.CONTACT_KEY: return contact
        case Self.DESCRIPTION_KEY: return description
        case Self.LICENSE_KEY: return license
        case Self.TERMS_KEY: return termsOfService
        case Self.TITLE_KEY: return title
        case Self.VERSION_KEY: return version
        case Self.SUMMARY_KEY: return summary
        case Self.TERMS_KEY: return termsOfService
        case Self.CONTACT_KEY: return contact
        
        
        default:
            // Für x-* Vendor Extensions einzelne Keys erlauben: "x-..." -> passenden Extension-Wert liefern
            if segmentName.hasPrefix("x-"), let exts = extensions {
                if let ext = exts.first(where: { $0.key == segmentName }) {
                    // Gib die strukturierte oder einfache Extension zurück
                    return ext.structuredExtension?.properties ?? ext.simpleExtensionValue
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
