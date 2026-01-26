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

public struct OpenAPISecurityScheme : KeyedElement , PointerNavigable {
   
    public static let BEARER_FORMAT_KEY = "bearerFormat"
    public static let DESCRIPTION_KEY = "description"
    public static let FLOWS_KEY = "flows"
    public static let LOCATION_KEY = "in"
    public static let NAME_KEY = "name"
    public static let TYPE_KEY = "type"
    public static let SCHEME_KEY = "scheme"
    public static let OPENID_CONNECT_URL_KEY = "openIdConnectUrl"
    public static let OAUTH2_METADATA_URL_KEY = "oauth2MetadataUrl"
    public static let DEPRECATED_KEY = "deprecated"
    public enum SecurityType : String , Sendable{
        case apiKey, http, mutualTLS, oauth2, openIdConnect
    }
    public enum APIKeyLocation : String, Sendable {
        case query,header,cookie
    }
    public enum Errors : LocalizedError {
        case missingSecurityType
        public var errorDescription: String? {
            switch self {
            case .missingSecurityType:
                "missing element 'type' on securitySchemes"
            }
        }
    }
    public static func initialize(_ map: StringDictionary) throws ->  InitializationResult<Self> {
        let element = try Self(load: map)
        return InitializationResult(value: element, diagnostics: [])

    }
    public init(load map: StringDictionary) throws {
       
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, valueType: String.self)
        if let ref  =  try OpenAPISchemaReference.initReference(from: (map)) {
            self.ref = ref
            return
        }
        if let securityRawType = map.readIfPresent(Self.TYPE_KEY, valueType: String.self),
           let securityType =  SecurityType(rawValue: securityRawType) {
            self.securityType = securityType
            switch securityType  {
            case .apiKey:
                self.name = map.readIfPresent(Self.NAME_KEY, valueType: String.self)
                if let locationRawValue = map.readIfPresent(Self.LOCATION_KEY, valueType: String.self),
                   let location = APIKeyLocation(rawValue: locationRawValue) {
                    self.location = location
                }
            case .http:
                self.httpScheme = map.readIfPresent(Self.SCHEME_KEY,valueType:  String.self)
                self.httpBearerFormat = map.readIfPresent(Self.BEARER_FORMAT_KEY, valueType: String.self)
            case .oauth2:
                self.flows = try map.readIfPresent(Self.FLOWS_KEY, objectType: OpenAPIOAuthFlows.self) 
                self.oauth2MetadataURL = map.readIfPresent(Self.OAUTH2_METADATA_URL_KEY, valueType: String.self)
            case .openIdConnect:
                self.openIdConnectURL = map.readIfPresent(Self.OPENID_CONNECT_URL_KEY, valueType: String.self)
                
            case .mutualTLS:
                return
            }
        }

         
       
    }
    public func element(for segmentName: String) throws -> NavigationResult {
       switch segmentName {
       case Self.TYPE_KEY : return .value(JSONValue(securityType?.rawValue))
       case Self.DESCRIPTION_KEY : return .value(JSONValue(description))
       case Self.NAME_KEY : return .value(JSONValue(name))
       case Self.LOCATION_KEY : return .value(JSONValue(location?.rawValue))
       case Self.SCHEME_KEY : return .value(JSONValue(httpScheme))
       case Self.BEARER_FORMAT_KEY : return  .value(JSONValue(httpBearerFormat))
        case Self.FLOWS_KEY : return .navigable(flows)
       case Self.OPENID_CONNECT_URL_KEY : return  .value(JSONValue(openIdConnectURL))
       case Self.OAUTH2_METADATA_URL_KEY : return  .value(JSONValue(openIdConnectURL))
       case Self.DEPRECATED_KEY : return  .value(JSONValue(deprecated))
       case OpenAPISchemaReference.REF_KEY: return .reference(ref?.reference)
       default:
       throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPISecurityScheme", segmentName)
        }
    }
    public var key: String?
    public var ref : OpenAPISchemaReference? = nil
    public var securityType : SecurityType?
    public var description : String? = nil
    public var name : String? = nil
    public var location : APIKeyLocation? = nil
    public var httpScheme : String? = nil
    public var httpBearerFormat : String? = nil
    public var flows : OpenAPIOAuthFlows? = nil
    public var openIdConnectURL : String? = nil
    public var oauth2MetadataURL : String? = nil
    public var deprecated : Bool? = nil
    
    
    
}
