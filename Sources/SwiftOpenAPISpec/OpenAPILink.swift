//
//  File.swift
//  
//
//  Created by Patric Dubois on 01.04.24.
//

import Foundation

public struct OpenAPILink : KeyedElement , PointerNavigable {
    public static let OPERATIION_REF_KEY = "operationRef"
    public static let OPERATIION_ID_KEY = "operationId"
    public static let PARAMETERS_KEY = "parameters"
    public static let REQUEST_BODY_KEY = "requestBody"
    public static let DESCRIPTION_KEY = "description"
    public static let SERVER_KEY = "server"
    public init(_ map: [String : Any]) throws {
        description = map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
        extensions = try OpenAPIExtension.extensionElements(map)
        operationRef = map.readIfPresent(Self.OPERATIION_REF_KEY, String.self)
        operationId = map.readIfPresent(Self.OPERATIION_ID_KEY, String.self)
        server = try map.mapIfPresent(Self.SERVER_KEY, OpenAPIServer.self)
        requestBody = map.readIfPresent(Self.REQUEST_BODY_KEY, String.self)
        if let refMap = map[OpenAPISchemaReference.REF_KEY] as? StringDictionary {
                   self.ref = try OpenAPISchemaReference(refMap)
               }
        if let ref = map[OpenAPISchemaReference.REF_KEY] as? String {
            self.ref =  OpenAPISchemaReference(ref: ref)
        }
        parameters = map.readIfPresent(Self.PARAMETERS_KEY, [String:String].self) ?? [:]
      
    }
    
    public func element(for segmentName: String) throws -> Any? {
       switch segmentName {
           case Self.OPERATIION_REF_KEY : return operationRef
           case Self.OPERATIION_ID_KEY :return operationId
           case Self.PARAMETERS_KEY :return parameters
           case Self.REQUEST_BODY_KEY :return requestBody
           case Self.DESCRIPTION_KEY :return description
           case Self.SERVER_KEY :return server
       case OpenAPISchemaReference.REF_KEY: return ref
       default:
           throw OpenAPIObject.Errors.unsupportedSegment("OpenAPILink", segmentName)
        }
    }
    public var key : String? = nil
    public var ref : OpenAPISchemaReference? = nil
    public var operationRef : String? = nil
    public var operationId : String? = nil
    public var description : String? = nil
    public var server : OpenAPIServer? = nil
    public var parameters : [String:String] = [:]
    public var requestBody : String? = nil
    public var userInfos =  [OpenAPIObject.UserInfo]()
    public var extensions : [OpenAPIExtension]?
 
}

