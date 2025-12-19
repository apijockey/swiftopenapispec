//
//  OpenAPICallBack.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 11.12.25.
//

import Foundation
public struct OpenAPICallBack : KeyedElement,PointerNavigable{
    
    //TODO: Call
    public func element(for segmentName: String) throws -> Any? {
       switch segmentName {
       case OpenAPISchemaReference.REF_KEY: return ref
           
       default:
           if let item = pathItems?.first(where: { $0.key == segmentName }) {
               return item
           }
           if segmentName.hasPrefix("x-"), let exts = extensions {
                           if let ext = exts.first(where: { $0.key == segmentName }) {
                               // Gib die strukturierte oder einfache Extension zurück
                               return ext.structuredExtension?.properties ?? ext.simpleExtensionValue
                           }
                       }
                       throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPICallBack", segmentName)
        }
    }
    
    
    public init(_ map : StringDictionary) throws {
        
        extensions = try OpenAPIExtension.extensionElements(map)
        if map.count > 0 {
            pathItems = []
            self.pathItems = try KeyedElementList<OpenAPIPathItem>.map(map)
        }
     
    }
    
    public var userInfos = [OpenAPISpecification.UserInfo]()
    public var extensions : [OpenAPIExtension]?
    public var pathItems : [OpenAPIPathItem]?
    public var key: String?
    public var ref : OpenAPISchemaReference? = nil
}
