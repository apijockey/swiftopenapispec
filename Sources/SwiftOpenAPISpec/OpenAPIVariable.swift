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
    
    public init(_ map: [String : Any]) throws {
        self.enumList = map.readIfPresent(Self.ENUM_KEY, [String].self)
        self.defaultValue = try map.tryRead(Self.DEFAULT_KEY, String.self,root: "variable")
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
        self.extensions = try OpenAPIExtension.extensionElements(map)
            
    }
    public func element(for segmentName: String) throws -> Any? {
        switch segmentName {
        case Self.ENUM_KEY : return enumList
        case Self.DEFAULT_KEY : return defaultValue
        case Self.DESCRIPTION_KEY : return description
            
        default:
            if segmentName.hasPrefix("x-"), let exts = extensions {
                if let ext = exts.first(where: { $0.key == segmentName }) {
                    // Gib die strukturierte oder einfache Extension zurück
                    return ext.structuredExtension?.properties ?? ext.simpleExtensionValue
                }
               
            }
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIVariable", segmentName)
        }
    }
    public var enumList : [String]? = nil
    public var ref: OpenAPISchemaReference? { nil}
    public var defaultValue : String?
    public var description : String? = nil
    
    public var extensions : [OpenAPIExtension]?
    
}
