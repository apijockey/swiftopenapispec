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

//
//  OpenAPIStringType.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 10.12.25.
//


public struct OpenAPIUnknownType : ThrowingHashMapInitiable  {
    public func validate() throws {
        
    }
    public var type: String?
    public static let TYPE_KEY : String = "type"
    public init(load map: StringDictionary) throws {
        self.type = map[Self.TYPE_KEY] as? String
    }
    public init () {
        
    }
    public static func initialize(_ map: StringDictionary) throws ->  InitializationResult<Self> {
           let element = try Self(load: map)
           return InitializationResult(value: element, diagnostics: [])
       }

    
    public func element(for segmentName: String) throws -> Any? {
      
          
        throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIUnknownType", segmentName)

        
    }
    
   
    
    
   
}
