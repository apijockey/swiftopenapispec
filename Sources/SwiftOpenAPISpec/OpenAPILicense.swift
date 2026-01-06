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
public struct OpenAPILicense : Codable , PointerNavigable {
    public func element(for segmentName: String) throws -> Any? {
        switch segmentName {
            case Self.NAME_KEY: return name
            case Self.IDENTIFIER_KEY: return identifier
            case Self.URL_KEY: return url
        default:
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPILicense", segmentName)
        }
    }
    
    public var ref: OpenAPISchemaReference? { nil}
    
    public static let NAME_KEY = "name"
    public static let IDENTIFIER_KEY = "identifier"
    public static let URL_KEY = "url"
    public init?(_ map : [String:Any?]) {
        guard let name = map[Self.NAME_KEY] as? String else {
            return nil
        }
        self.name = name
        if let text =  map[Self.IDENTIFIER_KEY] as? String {
            self.identifier = text
        }
        if let url = map[Self.URL_KEY] as? String {
            self.url = url
        }
        if let identifier = map[Self.URL_KEY] as? String {
            self.identifier = identifier
        }
    }
    public var name : String?
    public var identifier : String? = nil
    public var url : String? = nil
}
