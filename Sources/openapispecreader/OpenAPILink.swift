//
//  File.swift
//  
//
//  Created by Patric Dubois on 01.04.24.
//

import Foundation

struct OpenAPILink : KeyedElement {
    static let OPERATIION_REF_KEY = "operationRef"
    static let OPERATIION_ID_KEY = "operationId"
    static let PARAMETERS_KEY = "parameters"
    static let REQUEST_BODY_KEY = "requestBody"
    static let DESCRIPTION_KEY = "description"
    static let SERVER_KEY = "server"
    init(_ map: [AnyHashable : Any]) throws {
        operationRef = map.readIfPresent(Self.OPERATIION_REF_KEY, String.self)
        operationId = map.readIfPresent(Self.OPERATIION_ID_KEY, String.self)
        description = map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
        server = try map.mapIfPresent(Self.SERVER_KEY, OpenAPIServer.self)
        requestBody = map.readIfPresent(Self.REQUEST_BODY_KEY, String.self)
        parameters = map.readIfPresent(Self.PARAMETERS_KEY, [String:String].self) ?? [:]
    }
    var key : String? = nil
    var operationRef : String? = nil
    var operationId : String? = nil
    var description : String? = nil
    var server : OpenAPIServer? = nil
    var parameters : [String:String] = [:]
    var requestBody : String? = nil
 
}

