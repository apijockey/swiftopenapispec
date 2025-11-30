//
//  File.swift
//  
//
//  Created by Patric Dubois on 30.03.24.
//

import Foundation

struct OpenAPIOAuthFlow : ThrowingHashMapInitiable {
    static let AUTHORIZATIONURL_KEY = "authorizationUrl"
    static let TOKENURL_KEY = "tokenUrl"
    static let REFRESHURL_KEY = "refreshUrl"
    static let SCOPES_KEY = "scopes"
    init(_ map: [AnyHashable : Any]) throws {
        authorizationUrl = map.readIfPresent(Self.AUTHORIZATIONURL_KEY, String.self)
        tokenUrl = map.readIfPresent(Self.TOKENURL_KEY, String.self)
        refreshUrl = map.readIfPresent(Self.REFRESHURL_KEY, String.self)
        scopes = map.readIfPresent(Self.SCOPES_KEY, [String:String].self)
    }
    var authorizationUrl : String? = nil
    var tokenUrl : String? = nil
    var refreshUrl : String? = nil
    var scopes : [String:String]? = nil
}
