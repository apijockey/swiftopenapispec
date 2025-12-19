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
    public init(_ map: [String : Any]) throws {
        self.implicit = try map.mapIfPresent(Self.IMPLICIT_KEY, OpenAPIOAuthFlow.self)
        self.password = try map.mapIfPresent(Self.PASSWORD_KEY, OpenAPIOAuthFlow.self)
        self.clienCredentials = try map.mapIfPresent(Self.CLIENT_CREDENTIALS_KEY, OpenAPIOAuthFlow.self)
        self.authorizationCode = try map.mapIfPresent(Self.AUTHORIZATION_CODE_KEY, OpenAPIOAuthFlow.self)
    }
    public var implicit : OpenAPIOAuthFlow? = nil
    public var password : OpenAPIOAuthFlow? = nil
    public var clienCredentials : OpenAPIOAuthFlow? = nil
    public var authorizationCode : OpenAPIOAuthFlow? = nil
    public var deviceAuthorization : OpenAPIOAuthFlow? = nil
    public var userInfos =  [OpenAPISpecification.UserInfo]()
    public var ref: OpenAPISchemaReference? { nil}
}
