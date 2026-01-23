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
    public func element(for segmentName: String) throws -> Any? {
        switch segmentName {
        case Self.AUTHORIZATIONURL_KEY: return authorizationUrl
        case Self.DEVICE_AUTHORIZATIONURL_KEY: return deviceAuthorizationUrl
        case Self.TOKENURL_KEY: return tokenUrl
        case Self.REFRESHURL_KEY : return refreshUrl
            case Self.SCOPES_KEY : return scopes
        default:
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIOAuthFlow", segmentName)
        }
    }
    
    public static func initialize(_ map: StringDictionary) throws ->  InitializationResult<Self> {
        let element = try Self(load: map)
        return InitializationResult(value: element, diagnostics: [])
    }
    
    public static let AUTHORIZATIONURL_KEY = "authorizationUrl"
    public static let DEVICE_AUTHORIZATIONURL_KEY = "deviceAuthorizationUrl"
    public static let TOKENURL_KEY = "tokenUrl"
    public static let REFRESHURL_KEY = "refreshUrl"
    public static let SCOPES_KEY = "scopes"
    public init(load map: [String : Any]) throws {
        authorizationUrl = map.readIfPresent(Self.AUTHORIZATIONURL_KEY, String.self)
        tokenUrl = map.readIfPresent(Self.TOKENURL_KEY, String.self)
        refreshUrl = map.readIfPresent(Self.REFRESHURL_KEY, String.self)
        scopes = map.readIfPresent(Self.SCOPES_KEY, [String:String].self)
    }
    public var authorizationUrl : String? = nil
    public var deviceAuthorizationUrl : String? = nil
    public var tokenUrl : String? = nil
    public var refreshUrl : String? = nil
    public var scopes : [String:String]? = nil
  
    public var ref: OpenAPISchemaReference? { nil}
}
