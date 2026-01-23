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

//  Created by Patric Dubois on 28.03.24.
//

import Foundation


public struct OpenAPISchemaProperty: KeyedElement , PointerNavigable, OpenAPISchemaReferenceable {
  
    
    
   
    static let TYPE_KEY = "type"
    
    public static func initialize(_ map: StringDictionary) throws ->  InitializationResult<Self> {
           let element = try Self(load: map)
           return InitializationResult(value: element, diagnostics: [])
       }

    public init(load map: [String : Any]) throws {
        if let type = map[Self.TYPE_KEY] as? String {
            self.type = try OpenAPISchema.initialize(map).value
        }
        if let ref  =  try OpenAPISchemaReference.initReference(from: (map)) {
            self.ref = ref
            return
        }
        if map[OpenAPISchema.ONEOF_KEY] is [Any] {
            self.type = try OpenAPISchema(load: map)
        }
        else if map[OpenAPISchema.ANYOF_KEY] is [Any] {
            self.type = try OpenAPISchema(load: map)
        }
        else if map[OpenAPISchema.ALLOF_KEY] is [Any] {
            self.type = try OpenAPISchema(load: map)
        }
        if let discriminatorMap = map[OpenAPISchema.DISCRIMINATOR_KEY] as? [String : Any] {
            self.discriminator = try OpenAPIDiscriminator(load: discriminatorMap)
        }
      
   
    }
    
    public  var key : String? = nil
  
    public var ref : OpenAPISchemaReference?
    public var type : OpenAPISchema?
    public var discriminator : OpenAPIDiscriminator?
    
    public func element(for segmentName : String) throws -> Any? {
        switch segmentName {
            case OpenAPISchemaReference.REF_KEY : return self.type
            case Self.TYPE_KEY : return self.type
            case OpenAPISchema.ONEOF_KEY: return type
            case OpenAPISchema.ALLOF_KEY : return type
            case OpenAPISchema.DISCRIMINATOR_KEY : return self.discriminator
            
            default : throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPISchema", segmentName)
        }
    }
    
}

