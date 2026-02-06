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
public struct OpenAPIRequestBody : KeyedElement , PointerNavigable {
   
    public static let DESCRIPTION_KEY = "description"
    public static let REQUIRED_KEY = "required"
    public static let CONTENTS_KEY = "content"
    public  init(load map: StringDictionary,diagnostics: inout [Diagnostic])  throws {
        
        if case let .string(refKey) = map[OpenAPISchemaReference.REF_KEY]{
                    self.ref = OpenAPISchemaReference(ref: refKey)
            return
        }
        self.contents = try map.mapListIfPresent(Self.CONTENTS_KEY, objectType: OpenAPIMediaType.self, diagnostics: &diagnostics)
        self.description = map.readIfPresent(Self.DESCRIPTION_KEY, valueType: String.self, diagnostics : &diagnostics)
        
        self.required = map.readIfPresent(Self.REQUIRED_KEY, valueType: Bool.self, diagnostics : &diagnostics) ?? false
        
    }
   

    public var key : String?
    
    public var description : String? = nil
    public var required : Bool = false
    public var contents : [OpenAPIMediaType] = []
   
    public var ref : OpenAPISchemaReference? = nil
    public func element(for segmentName : String) throws -> NavigationResult {
        switch segmentName {
        case Self.CONTENTS_KEY : .navigableCollection(contents)
            default : throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIRequestBody", segmentName)
        }
    }
    
}

