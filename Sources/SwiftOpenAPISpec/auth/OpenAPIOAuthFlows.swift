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

public struct OpenAPIOAuthFlows : ThrowingHashMapInitiable, PointerNavigable {
    public func element(for segmentName: String) throws -> Any? {
        switch segmentName {
            case Self.IMPLICIT_KEY: return self.implicit as Any?
            case Self.PASSWORD_KEY: return self.password as Any?
            case Self.CLIENT_CREDENTIALS_KEY: return self.clienCredentials as Any?
            case Self.AUTHORIZATION_CODE_KEY: return self.authorizationCode as Any?
            case Self.DEVICE_AUTHORIZATION_KEY: return self.deviceAuthorization as Any?
        default:
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIOAuthFlows", segmentName)
        }
    }
    
 
    
    public static let IMPLICIT_KEY  = "implicit"
    public static let PASSWORD_KEY  = "password"
    public static let CLIENT_CREDENTIALS_KEY  = "clientCredentials"
    public static let AUTHORIZATION_CODE_KEY  = "authorizationCode"
    public static let DEVICE_AUTHORIZATION_KEY  = "deviceAuthorization"
    public init(load map: [String : Any]) throws {
        self.implicit = try map.mapIfPresent(Self.IMPLICIT_KEY, OpenAPIOAuthFlow.self)
        self.password = try map.mapIfPresent(Self.PASSWORD_KEY, OpenAPIOAuthFlow.self)
        self.clienCredentials = try map.mapIfPresent(Self.CLIENT_CREDENTIALS_KEY, OpenAPIOAuthFlow.self)
        self.authorizationCode = try map.mapIfPresent(Self.AUTHORIZATION_CODE_KEY, OpenAPIOAuthFlow.self)
    }
    public static func initialize(_ map: StringDictionary) throws -> InitializationResult<Self> {
        let element = try Self(load: map)
        return InitializationResult(value: element, diagnostics: [])
    }
    public var implicit : OpenAPIOAuthFlow? = nil
    public var password : OpenAPIOAuthFlow? = nil
    public var clienCredentials : OpenAPIOAuthFlow? = nil
    public var authorizationCode : OpenAPIOAuthFlow? = nil
    public var deviceAuthorization : OpenAPIOAuthFlow? = nil
   
    public var ref: OpenAPISchemaReference? { nil}
}
