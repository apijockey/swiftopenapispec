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
//  Created by Patric Dubois on 29.03.24.
//

import Foundation


// initally a special type to handle the ref element on an OpenaPISchema, now maybe more a base type for all elements, that can hold a ref, meas, such an element must be included, where a ref can occur, try with OpenAPIExample
public struct OpenAPISchemaReference  : ThrowingHashMapInitiable, PointerNavigable{
    public func validate() throws {
        
    }
    
    public func element(for segmentName: String) throws -> NavigationResult {
        if segmentName == Self.REF_KEY {
            return .reference(reference)
        }
        throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPISchemaReference", segmentName)
    }
    
    public static let REF_KEY = "$ref"
    public static let SUMMARY_KEY = "summary"
    public static let DESCRIPTION_KEY = "description"
    public static func initReference(from map: StringDictionary) throws -> OpenAPISchemaReference? {
        if let refMap = map[OpenAPISchemaReference.REF_KEY] as? StringDictionary {
            return  try OpenAPISchemaReference(load: refMap)
        }
        else  if let refString = map[OpenAPISchemaReference.REF_KEY] as? String {
            return  OpenAPISchemaReference(ref: refString)
        }
        else {
            return nil
        }
        
    }
    public static func initialize(_ map: StringDictionary) throws ->  InitializationResult<Self> {
           let element = try Self(load: map)
           return InitializationResult(value: element, diagnostics: [])
       }

    public init(load map: [String : Any]) throws {
        self.reference = map.readIfPresent(Self.REF_KEY, String.self)
        self.summary = map.readIfPresent(Self.SUMMARY_KEY, String.self)
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, String.self)
        
    }
    public init(ref: String) {
        self.reference = ref
    }
    
    public var reference : String? = nil
    public var summary : String? = nil
    public var description : String? = nil
   
}
