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
/// A structure representing the metadata information about an OpenAPI specification.
///
/// The `OpenAPIInfo` object provides metadata about the API, including its title, version, description,
/// terms of service, contact information, license information, and version of the OpenAPI specification.
///
/// This information is typically used to provide context and documentation about the API itself.
public struct OpenAPIInfo : ThrowingHashMapInitiable, PointerNavigable {
  
    
    
    
    static let CONTACT_KEY = "contact"
    static let DESCRIPTION_KEY = "description"
    static let LICENSE_KEY = "license"
    static let SUMMARY_KEY = "summary"
    static let TERMS_KEY = "termsOfService"
    static let TITLE_KEY = "title"
    static let VERSION_KEY = "version"
    /// Creates an `OpenAPIInfo` instance from a dictionary representation.
    ///
    /// - Parameters:
    ///   - map: A dictionary containing the OpenAPI info data
    ///   - diagnostics: An array to collect any diagnostic messages during parsing
    ///   - pointer: A JSON pointer indicating the location in the source document
    /// - Throws: An error if the input data is invalid or required fields are missing
    public init(load map: StringDictionary, diagnostics: inout [Diagnostic],pointer : String) throws {
        self.version = map.readIfPresent(Self.VERSION_KEY, valueType: String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.VERSION_KEY))
        self.title = map.readIfPresent(Self.TITLE_KEY,valueType: String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.TITLE_KEY))
        self.summary = map.readIfPresent(Self.SUMMARY_KEY,valueType: String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.SUMMARY_KEY))
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY,valueType: String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.DESCRIPTION_KEY))
        self.termsOfService = map.readIfPresent( Self.TERMS_KEY,valueType: String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.TERMS_KEY))
        self.contact = try  map.readIfPresent(Self.CONTACT_KEY, objectType: OpenAPIContact.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.CONTACT_KEY))
        self.license = try map.readIfPresent(Self.LICENSE_KEY, objectType: OpenAPILicense.self, diagnostics: &diagnostics, pointer: JSONPointer.join(pointer, Self.LICENSE_KEY))
        extensions = try OpenAPIExtension.extensionElements(map, &diagnostics,pointer: JSONPointer.join(pointer, "extensions"))
        
        // Validate unsupported keys
        diagnostics.append(contentsOf: map.diagnoseUnsupportedElements(supportedKeys: Self.supportedKeys, pointer: pointer))
    }
    
    /// The set of keys supported by OpenAPI Info object
    private static var supportedKeys: Set<String> {
        [
            Self.TITLE_KEY,
            Self.DESCRIPTION_KEY,
            Self.TERMS_KEY,
            Self.CONTACT_KEY,
            Self.LICENSE_KEY,
            Self.VERSION_KEY,
            Self.SUMMARY_KEY
        ]
    }
   
    /// Navigates to a specific element within the OpenAPI info structure.
    ///
    /// - Parameter segmentName: The name of the element to navigate to
    /// - Returns: A `NavigationResult` containing either the requested value or a navigable element
    /// - Throws: An error if the requested element does not exist
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
                    
                    return .value(ext.value)
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
    public var summary : String?
    public var version : String?
}
