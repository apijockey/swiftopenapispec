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
public struct OpenAPILicense : ThrowingHashMapInitiable , PointerNavigable {
    public init(load map: StringDictionary) throws {
        self.name = map.readIfPresent(Self.NAME_KEY, valueType: String.self)
        self.identifier = map.readIfPresent(Self.IDENTIFIER_KEY, valueType: String.self)
        self.url = map.readIfPresent(Self.URL_KEY, valueType: String.self)
        
    }
    
    public static func initialize(_ map: StringDictionary) throws ->  InitializationResult<Self> {
           let element = try Self(load: map)
           return InitializationResult(value: element, diagnostics: [])
       }
    public func element(for segmentName: String) throws -> NavigationResult {
        switch segmentName {
            case Self.NAME_KEY: return .value(JSONValue(name))
            case Self.IDENTIFIER_KEY: return .value(JSONValue(identifier))
            case Self.URL_KEY: return .value(JSONValue(url))
        default:
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPILicense", segmentName)
        }
    }
    
    
    public var ref: OpenAPISchemaReference? { nil}
    
    public static let NAME_KEY = "name"
    public static let IDENTIFIER_KEY = "identifier"
    public static let URL_KEY = "url"
   
    public var name : String?
    public var identifier : String? = nil
    public var url : String? = nil
}
