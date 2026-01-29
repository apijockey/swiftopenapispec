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
    public func element(for segmentName: String) throws -> NavigationResult {
        switch segmentName {
        case Self.IMPLICIT_KEY:
            let value  = try JSONValue(self.implicit)
            return .value(value)
            case Self.PASSWORD_KEY:
            let value = try JSONValue(self.password)
            return .value(value)
            case Self.CLIENT_CREDENTIALS_KEY:
            let value = try JSONValue(clienCredentials)
            return .value(value)
            case Self.AUTHORIZATION_CODE_KEY:
            let value = try JSONValue(self.authorizationCode)
            return .value(value)
            case Self.DEVICE_AUTHORIZATION_KEY:
            let value = try JSONValue(self.deviceAuthorization )
            return .value(value)
        default:
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIOAuthFlows", segmentName)
        }
    }
    
 
    
    public static let IMPLICIT_KEY  = "implicit"
    public static let PASSWORD_KEY  = "password"
    public static let CLIENT_CREDENTIALS_KEY  = "clientCredentials"
    public static let AUTHORIZATION_CODE_KEY  = "authorizationCode"
    public static let DEVICE_AUTHORIZATION_KEY  = "deviceAuthorization"
    public init(load map: StringDictionary,_ diagnostics: inout [Diagnostic]) throws {
        self.implicit = try map.readIfPresent(Self.IMPLICIT_KEY, objectType: OpenAPIOAuthFlow.self)
        self.password = try map.readIfPresent(Self.PASSWORD_KEY, objectType: OpenAPIOAuthFlow.self)
        self.clienCredentials = try map.readIfPresent(Self.CLIENT_CREDENTIALS_KEY, objectType: OpenAPIOAuthFlow.self)
        self.authorizationCode = try map.readIfPresent(Self.AUTHORIZATION_CODE_KEY, objectType: OpenAPIOAuthFlow.self)
    }
   
    public var implicit : OpenAPIOAuthFlow? = nil
    public var password : OpenAPIOAuthFlow? = nil
    public var clienCredentials : OpenAPIOAuthFlow? = nil
    public var authorizationCode : OpenAPIOAuthFlow? = nil
    public var deviceAuthorization : OpenAPIOAuthFlow? = nil
   
    public var ref: OpenAPISchemaReference? { nil}
}
