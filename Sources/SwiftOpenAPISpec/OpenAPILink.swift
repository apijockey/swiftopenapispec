//
//  File.swift
//  
//
//  Created by Patric Dubois on 01.04.24.
//

import Foundation

public struct OpenAPILink : KeyedElement {
    public static let OPERATIION_REF_KEY = "operationRef"
    public static let OPERATIION_ID_KEY = "operationId"
    public static let PARAMETERS_KEY = "parameters"
    public static let REQUEST_BODY_KEY = "requestBody"
    public static let DESCRIPTION_KEY = "description"
    public static let SERVER_KEY = "server"
    public init(_ map: [String : Any]) throws {
        operationRef = map.readIfPresent(Self.OPERATIION_REF_KEY, String.self)
        operationId = map.readIfPresent(Self.OPERATIION_ID_KEY, String.self)
        description = map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
        server = try map.mapIfPresent(Self.SERVER_KEY, OpenAPIServer.self)
        requestBody = map.readIfPresent(Self.REQUEST_BODY_KEY, String.self)
        parameters = map.readIfPresent(Self.PARAMETERS_KEY, [String:String].self) ?? [:]
        extensions = try OpenAPIExtension.extensionElements(map)
    }
    public var key : String? = nil
    public var operationRef : String? = nil
    public var operationId : String? = nil
    public var description : String? = nil
    public var server : OpenAPIServer? = nil
    public var parameters : [String:String] = [:]
    public var requestBody : String? = nil
    public var userInfos =  [OpenAPIObject.UserInfo]()
    public var extensions : [OpenAPIExtension]?
 
}

