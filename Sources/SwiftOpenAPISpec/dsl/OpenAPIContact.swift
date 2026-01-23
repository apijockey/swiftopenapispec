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
public struct OpenAPIContact : ThrowingHashMapInitiable , PointerNavigable {
    public func element(for segmentName: String) throws -> Any? {
        switch segmentName {
        case Self.EMAIL_KEY: return email
        case Self.NAME_KEY: return name
        case Self.URL_KEY: return url
        default: throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIContact", segmentName)
        }
    }
    
   
    public static let EMAIL_KEY = "email"
    public  static let NAME_KEY = "name"
    public static let URL_KEY = "url"
   
    public init(load map : StringDictionary) throws {
        if let name = map[Self.NAME_KEY] as? String {
            self.name = name
        }
        if let url = map[Self.URL_KEY] as? String {
            self.url = url
        }
        if let email = map[Self.EMAIL_KEY] as? String {
            self.email = email
        }
        extensions = try OpenAPIExtension.extensionElements(map)
    }
    public static func initialize(_ map: StringDictionary) throws ->  InitializationResult<Self> {
        let element = try Self(load: map)
        return InitializationResult(value: element, diagnostics: [])
    }
    
    public var email : String? = nil
    public var extensions : [OpenAPIExtension]?
    public  var name : String? = nil
    public var url : String? = nil
    
    public var ref: OpenAPISchemaReference? { nil}
}
