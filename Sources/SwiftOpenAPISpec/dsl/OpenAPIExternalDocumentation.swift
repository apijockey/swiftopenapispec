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
// SPDX-License-Identifier: Apache-2.0
//  Created by Patric Dubois on 30.03.24.
//

import Foundation

public struct OpenAPIExternalDocumentation : ThrowingHashMapInitiable, PointerNavigable {
    
    public static let URL_KEY = "url"
    public static let DESCRIPTION_KEY = "desccription"
    
    public func element(for segmentName: String) throws -> NavigationResult {
        switch segmentName {
        case Self.URL_KEY: return .value(JSONValue(url))
        case Self.DESCRIPTION_KEY: return .value(JSONValue(self.description))
        default:
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIExternalDocumentation", segmentName)
        }
    }
    
  
  

    public init(load map: StringDictionary, diagnostics: inout [Diagnostic]) throws {
        self.url = map.readIfPresent("url", valueType: String.self, diagnostics : &diagnostics)
        self.description = map.readIfPresent("description", valueType: String.self, diagnostics : &diagnostics)
    }
    public var description : String? = nil
    public var url : String?
   
   
    
}
