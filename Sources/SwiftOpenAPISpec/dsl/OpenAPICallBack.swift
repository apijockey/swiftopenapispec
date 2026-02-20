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
    
    public static let CALL_BACK_KEY = "callback"
    
    public func element(for segmentName: String) throws -> NavigationResult {
       switch segmentName {
       case OpenAPISchemaReference.REF_KEY: return  .reference(ref?.reference)
           
       default:
           if let item = pathItems?.first(where: { $0.key == segmentName }) {
               return .navigable(item)
           }
           if segmentName.hasPrefix("x-"), let exts = extensions {
                           if let ext = exts.first(where: { $0.key == segmentName }) {
                               return .value(ext.value)
                           }
                       }
                       throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPICallBack", segmentName)
        }
    }
    
    
    public init(load map: StringDictionary,diagnostics: inout [Diagnostic],pointer : String) throws {
        
        if case let .string(refKey) = map[OpenAPISchemaReference.REF_KEY]{
                    self.ref = OpenAPISchemaReference(ref: refKey)
            return
        }
        extensions = try OpenAPIExtension.extensionElements(map, &diagnostics,pointer: JSONPointer.join(pointer, "extensions"))
        if map.count > 0 {
            pathItems = []
            self.pathItems =  try map.mapListIfPresent(objectType: OpenAPIPathItem.self, pointer: JSONPointer.join(pointer, Self.CALL_BACK_KEY))
        }
        //keys are expressions
        
    }
    
    /// The set of keys supported by OpenAPI Callback object (excluding dynamic extensions and $ref)
    /// Callbacks are special as they support any URL as a key for path items
    private static var supportedKeys: Set<String> {
        [
            OpenAPISchemaReference.REF_KEY,
            CALL_BACK_KEY
            
            
        ] // Callback supports any key as a dynamic callback URL, plus extensions (x-*) and $ref
    }
  
    public var extensions : [OpenAPIExtension]?
    public var pathItems : [OpenAPIPathItem]?
    public var key: String?
    public var ref : OpenAPISchemaReference? = nil
}
