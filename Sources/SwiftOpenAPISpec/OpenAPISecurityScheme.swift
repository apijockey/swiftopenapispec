//
//  File.swift
//  
//
//  Created by Patric Dubois on 30.03.24.
//

import Foundation

struct OpenAPISecurityScheme : KeyedElement {
   
    
    static let TYPE_KEY = "type"
    static let DESCRIPTION_KEY = "description"
    static let NAME_KEY = "name"
    static let LOCATION_KEY = "in"
    static let SCHEME_KEY = "scheme"
    static let BEARER_FORMAT_KEY = "bearerFormat"
    static let FLOWS_KEY = "flows"
    static let OPENID_CONNECT_URL_KEY = "openIdConnectUrl"
    enum SecurityType : String {
        case apiKey, http, mutualTLS, oauth2, openIdConnect
    }
    enum APIKeyLocation : String {
        case query,header,cookie
    }
    enum Errors : LocalizedError {
        case missingSecurityType
        var errorDescription: String? {
            switch self {
            case .missingSecurityType:
                "missing element 'type' on securitySchemes"
            }
        }
    }
    init(_ map: [AnyHashable : Any]) throws {
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
        guard let securityRawType = map.readIfPresent(Self.TYPE_KEY, String.self),
        let securityType =  SecurityType(rawValue: securityRawType) else {
            throw Self.Errors.missingSecurityType
        }
        self.securityType = securityType
         
        switch securityType  {
        case .apiKey:
            self.apiKeyName = map.readIfPresent(Self.NAME_KEY, String.self)
            if let locationRawValue = map.readIfPresent(Self.LOCATION_KEY, String.self),
               let location = APIKeyLocation(rawValue: locationRawValue) {
                self.ApiKeyIn = location
            }
        case .http:
            self.httpScheme = map.readIfPresent(Self.SCHEME_KEY, String.self)
            self.httpBearerFormat = map.readIfPresent(Self.BEARER_FORMAT_KEY, String.self)
        case .oauth2:
            if let flowsMap = map.readIfPresent(Self.FLOWS_KEY, [AnyHashable:Any].self) {
                self.flows = try OpenAPIOAuthFlows(flowsMap)
            }
        case .openIdConnect:
            self.openIdConnectURL = map.readIfPresent(Self.OPENID_CONNECT_URL_KEY, String.self)
            
        case .mutualTLS:
            return
        }
    }
    var key: String?
    var securityType : SecurityType
    var description : String? = nil
    var apiKeyName : String? = nil
    var ApiKeyIn : APIKeyLocation? = nil
    var httpScheme : String? = nil
    var httpBearerFormat : String? = nil
    var flows : OpenAPIOAuthFlows? = nil
    var openIdConnectURL : String? = nil
    
}
