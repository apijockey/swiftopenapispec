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

/*
 * Copyright 2025 
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

//
//  File.swift
//  
//
//  Created by Patric Dubois on 30.03.24.
//

import Foundation

public struct OpenAPIOAuthFlow : ThrowingHashMapInitiable, PointerNavigable {
   
   
    public init(load map: StringDictionary,  diagnostics: inout [Diagnostic]) throws {
        authorizationUrl = map.readIfPresent(Self.AUTHORIZATIONURL_KEY,valueType: String.self, diagnostics : &diagnostics)
        tokenUrl = map.readIfPresent(Self.TOKENURL_KEY, valueType: String.self, diagnostics : &diagnostics)
        refreshUrl = map.readIfPresent(Self.REFRESHURL_KEY, valueType: String.self, diagnostics : &diagnostics)
        scopes = map.readIfPresent(Self.SCOPES_KEY,valueType:  [String:String].self, diagnostics : &diagnostics)
        if case let .object(scopes) = map[Self.SCOPES_KEY] {
            self.scopes = [String:String]()
            for scope in scopes {
                if case let .string(value) = scope.value {
                    self.scopes?[scope.key] = value
                }
            }
        }
    }
    
    public func element(for segmentName: String) throws -> NavigationResult {
        switch segmentName {
        case Self.AUTHORIZATIONURL_KEY: return .value(JSONValue(string: authorizationUrl))
        case Self.DEVICE_AUTHORIZATIONURL_KEY: return .value(JSONValue(string: deviceAuthorizationUrl))
        case Self.TOKENURL_KEY: return .value(JSONValue(string: tokenUrl))
        case Self.REFRESHURL_KEY : return .value(JSONValue(string: refreshUrl))
        case Self.SCOPES_KEY :
            let value = try JSONValue(scopes)
            return  .value(value)
        default:
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIOAuthFlow", segmentName)
        }
    }
    
   
    
   
    
    public static let AUTHORIZATIONURL_KEY = "authorizationUrl"
    public static let DEVICE_AUTHORIZATIONURL_KEY = "deviceAuthorizationUrl"
    public static let TOKENURL_KEY = "tokenUrl"
    public static let REFRESHURL_KEY = "refreshUrl"
    public static let SCOPES_KEY = "scopes"
   
    public var authorizationUrl : String? = nil
    public var deviceAuthorizationUrl : String? = nil
    public var tokenUrl : String? = nil
    public var refreshUrl : String? = nil
    public var scopes : [String:String]? = nil
  
   
}
