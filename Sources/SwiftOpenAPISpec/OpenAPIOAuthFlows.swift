//
//  File.swift
//  
//
//  Created by Patric Dubois on 30.03.24.
//

import Foundation

public struct OpenAPIOAuthFlows : ThrowingHashMapInitiable {
    public static let IMPLICIT_KEY  = "implicit"
    public static let PASSWORD_KEY  = "password"
    public static let CLIENT_CREDENTIALS_KEY  = "clientCredentials"
    public static let AUTHORIZATION_CODE_KEY  = "authorizationCode"
    public init(_ map: [AnyHashable : Any]) throws {
        self.implicit = try map.mapIfPresent(Self.IMPLICIT_KEY, OpenAPIOAuthFlow.self)
        self.password = try map.mapIfPresent(Self.PASSWORD_KEY, OpenAPIOAuthFlow.self)
        self.clienCredentials = try map.mapIfPresent(Self.CLIENT_CREDENTIALS_KEY, OpenAPIOAuthFlow.self)
        self.authorizationCode = try map.mapIfPresent(Self.AUTHORIZATION_CODE_KEY, OpenAPIOAuthFlow.self)
    }
    public var implicit : OpenAPIOAuthFlow? = nil
    public var password : OpenAPIOAuthFlow? = nil
    public var clienCredentials : OpenAPIOAuthFlow? = nil
    public var authorizationCode : OpenAPIOAuthFlow? = nil
}
