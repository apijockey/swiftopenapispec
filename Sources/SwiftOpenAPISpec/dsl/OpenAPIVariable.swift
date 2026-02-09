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
//  Created by Patric Dubois on 30.03.24.
//

import Foundation

public struct OpenAPIVariable : KeyedElement , PointerNavigable {
    public static let ENUM_KEY = "enum"
    public static let DEFAULT_KEY = "default"
    public static let DESCRIPTION_KEY = "description"
   
    public var key: String?
  

    public init(load map: StringDictionary, diagnostics: inout [Diagnostic],pointer : String) throws {
        self.enumList = try map.mapListIfPresent(Self.ENUM_KEY, objectType: OpenAPIType.self, diagnostics: &diagnostics, pointer: pointer)
        self.defaultValue = map.readIfPresent(Self.DEFAULT_KEY,  valueType: String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.DEFAULT_KEY))
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, valueType: String.self, diagnostics : &diagnostics, pointer: JSONPointer.join(pointer, Self.DESCRIPTION_KEY))
        self.extensions = try OpenAPIExtension.extensionElements(map, &diagnostics,pointer: JSONPointer.join(pointer, "extensions"))
            
    }
    public func element(for segmentName: String) throws -> NavigationResult{
        switch segmentName {
        case Self.ENUM_KEY :
            let value = try JSONValue(enumList)
            return .value(value)
        case Self.DEFAULT_KEY : return .value(JSONValue(defaultValue))
        case Self.DESCRIPTION_KEY : return .value(JSONValue(description))
            
        default:
//            if segmentName.hasPrefix("x-"), let exts = extensions {
//                if let ext = exts.first(where: { $0.key == segmentName }) {
//                    // Gib die strukturierte oder einfache Extension zurück
//                    return ext.structuredExtension?.properties ?? ext.simpleExtensionValue
//                }
//               
//            }
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIVariable", segmentName)
        }
    }
    public var enumList : [OpenAPIType]? = nil
    public var defaultValue : String?
    public var description : String? = nil
    
    public var extensions : [OpenAPIExtension]?
    
}
