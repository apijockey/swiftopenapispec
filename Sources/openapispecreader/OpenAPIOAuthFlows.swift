//
//  File.swift
//  
//
//  Created by Patric Dubois on 30.03.24.
//

import Foundation

struct OpenAPIOAuthFlows : ThrowingHashMapInitiable {
    static let IMPLICIT_KEY  = "implicit"
    static let PASSWORD_KEY  = "password"
    static let CLIENT_CREDENTIALS_KEY  = "clientCredentials"
    static let AUTHORIZATION_CODE_KEY  = "authorizationCode"
    init(_ map: [AnyHashable : Any]) throws {
        self.implicit = try map.mapIfPresent(Self.IMPLICIT_KEY, OpenAPIOAuthFlow.self)
        self.password = try map.mapIfPresent(Self.PASSWORD_KEY, OpenAPIOAuthFlow.self)
        self.clienCredentials = try map.mapIfPresent(Self.CLIENT_CREDENTIALS_KEY, OpenAPIOAuthFlow.self)
        self.authorizationCode = try map.mapIfPresent(Self.AUTHORIZATION_CODE_KEY, OpenAPIOAuthFlow.self)
    }
    var implicit : OpenAPIOAuthFlow? = nil
    var password : OpenAPIOAuthFlow? = nil
    var clienCredentials : OpenAPIOAuthFlow? = nil
    var authorizationCode : OpenAPIOAuthFlow? = nil
}
