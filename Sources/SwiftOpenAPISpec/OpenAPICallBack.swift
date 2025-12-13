//
//  OpenAPICallBack.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 11.12.25.
//

import Foundation
public struct OpenAPICallBack : KeyedElement,PointerNavigable{
    public func element(for segmentName: String) throws -> Any? {
        try Self.element(for: segmentName)
    }
    
    
    public init(_ map : StringDictionary) throws {
        
        extensions = try OpenAPIExtension.extensionElements(map)
        if map.count > 0 {
            pathItems = []
            self.pathItems = try KeyedElementList<OpenAPIPathItem>.map(map)
        }
     
    }
    
    public var userInfos = [OpenAPIObject.UserInfo]()
    public var extensions : [OpenAPIExtension]?
    public var pathItems : [OpenAPIPathItem]?
    public var key: String?
}
