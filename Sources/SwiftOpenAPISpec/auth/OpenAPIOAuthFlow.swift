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
    
   
    
    public static let AUTHORIZATIONURL_KEY = "authorizationUrl"
    public static let DEVICE_AUTHORIZATIONURL_KEY = "deviceAuthorizationUrl"
    public static let TOKENURL_KEY = "tokenUrl"
    public static let REFRESHURL_KEY = "refreshUrl"
    public static let SCOPES_KEY = "scopes"
    public init(_ map: [String : Any]) throws {
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
    public var userInfos =  [OpenAPISpecification.UserInfo]()
    public var ref: OpenAPISchemaReference? { nil}
}
