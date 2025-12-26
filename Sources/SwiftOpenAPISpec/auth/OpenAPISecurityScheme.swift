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
    public init(_ map: [String : Any]) throws {
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
        if let refMap = map[OpenAPISchemaReference.REF_KEY] as? StringDictionary {
                   self.ref = try OpenAPISchemaReference(refMap)
               }
        if let ref = map[OpenAPISchemaReference.REF_KEY] as? String {
                    self.ref = OpenAPISchemaReference(ref: ref)
                       }
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
            self.oauth2MetadataURL = map.readIfPresent(Self.OAUTH2_METADATA_URL_KEY, String.self)
        case .openIdConnect:
            self.openIdConnectURL = map.readIfPresent(Self.OPENID_CONNECT_URL_KEY, String.self)
            
        case .mutualTLS:
            return
        }
    }
    public func element(for segmentName: String) throws -> Any? {
       switch segmentName {
       case Self.TYPE_KEY : return securityType.rawValue
       case Self.DESCRIPTION_KEY : return description
       case Self.NAME_KEY : return name
       case Self.LOCATION_KEY : return location?.rawValue
       case Self.SCHEME_KEY : return httpScheme
       case Self.BEARER_FORMAT_KEY : return  httpBearerFormat
       case Self.FLOWS_KEY : return flows
       case Self.OPENID_CONNECT_URL_KEY : return openIdConnectURL
       case Self.OAUTH2_METADATA_URL_KEY : return openIdConnectURL
       case Self.DEPRECATED_KEY : return deprecated
       case OpenAPISchemaReference.REF_KEY: return ref
       default:
       throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPISecurityScheme", segmentName)
        }
    }
    public var key: String?
    public var ref : OpenAPISchemaReference? = nil
    public var securityType : SecurityType
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
