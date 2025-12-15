//
//  File.swift
//  
//
//  Created by Patric Dubois on 30.03.24.
//

import Foundation

public struct OpenAPISecurityScheme : KeyedElement , PointerNavigable {
   
    
    public static let TYPE_KEY = "type"
    public static let DESCRIPTION_KEY = "description"
    public static let NAME_KEY = "name"
    public static let LOCATION_KEY = "in"
    public static let SCHEME_KEY = "scheme"
    public static let BEARER_FORMAT_KEY = "bearerFormat"
    public static let FLOWS_KEY = "flows"
    public static let OPENID_CONNECT_URL_KEY = "openIdConnectUrl"
    public static let DEPRECATED_KEY = "deprecated"
    public enum SecurityType : String {
        case apiKey, http, mutualTLS, oauth2, openIdConnect
    }
    public enum APIKeyLocation : String {
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
    public init(_ map: [String : Any]) throws {
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
        guard let securityRawType = map.readIfPresent(Self.TYPE_KEY, String.self),
        let securityType =  SecurityType(rawValue: securityRawType) else {
            throw Self.Errors.missingSecurityType
        }
        self.securityType = securityType
         
        switch securityType  {
        case .apiKey:
            self.name = map.readIfPresent(Self.NAME_KEY, String.self)
            if let locationRawValue = map.readIfPresent(Self.LOCATION_KEY, String.self),
               let location = APIKeyLocation(rawValue: locationRawValue) {
                self.location = location
            }
        case .http:
            self.httpScheme = map.readIfPresent(Self.SCHEME_KEY, String.self)
            self.httpBearerFormat = map.readIfPresent(Self.BEARER_FORMAT_KEY, String.self)
        case .oauth2:
            if let flowsMap = map.readIfPresent(Self.FLOWS_KEY, StringDictionary.self) {
                self.flows = try OpenAPIOAuthFlows(flowsMap)
            }
        case .openIdConnect:
            self.openIdConnectURL = map.readIfPresent(Self.OPENID_CONNECT_URL_KEY, String.self)
            
        case .mutualTLS:
            return
        }
    }
    public func element(for segmentName: String) throws -> Any? {
        try Self.element(for: segmentName)
    }
    public var key: String?
    public var ref : String? // PointerNavigable
    public var securityType : SecurityType
    public var description : String? = nil
    public var name : String? = nil
    public var location : APIKeyLocation? = nil
    public var httpScheme : String? = nil
    public var httpBearerFormat : String? = nil
    public var flows : OpenAPIOAuthFlows? = nil
    public var openIdConnectURL : String? = nil
    public var deprecated : Bool? = nil
    public var userInfos =  [OpenAPIObject.UserInfo]()
    
    
}
