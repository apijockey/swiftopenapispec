/*
 * Copyright 2025 CgSe Computergrafik und Softwareentwicklung GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
// Created by Patric Dubois on 11.12.25.
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
    
   
    public var extensions : [OpenAPIExtension]?
    public var pathItems : [OpenAPIPathItem]?
    public var key: String?
    public var ref : OpenAPISchemaReference? = nil
}
