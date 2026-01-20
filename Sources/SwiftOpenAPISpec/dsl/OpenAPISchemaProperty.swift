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


public struct OpenAPISchemaProperty: KeyedElement , PointerNavigable, OpenAPISchemaReferenceable, Equatable {
    public static func == (lhs: OpenAPISchemaProperty, rhs: OpenAPISchemaProperty) -> Bool {
        // Compare type via existential-safe isEqual(to:)
        let typesEqual: Bool = {
            switch (lhs.type, rhs.type) {
            case (nil, nil):
                return true
            case let (l?, r?):
                return l.isEqual(to: r)
            default:
                return false
            }
        }()

        return typesEqual &&
        lhs.ref == rhs.ref &&
        lhs.key == rhs.key
    }
    
    
   
    static let TYPE_KEY = "type"
    
    public init(_ map: [String : Any]) throws {
        if let type = map[Self.TYPE_KEY] as? String,
            let validatableType = OpenAPISchemaType.validatableType(type) {
            self.type = try validatableType.init(map)
        }
        if let ref  =  try OpenAPISchemaReference.initReference(from: (map)) {
            self.ref = ref
            return
        }
        if map[OpenAPISchema.ONEOF_KEY] is [Any] {
            self.type = try OpenAPIOneOfType(map)
        }
        else if map[OpenAPISchema.ANYOF_KEY] is [Any] {
            self.type = try OpenAPIAnyOfType(map)
        }
        else if map[OpenAPISchema.ALLOF_KEY] is [Any] {
            self.type = try OpenAPIAllOfType(map)
        }
        if let discriminatorMap = map[OpenAPISchema.DISCRIMINATOR_KEY] as? [String : Any] {
            self.discriminator = try OpenAPIDiscriminator(discriminatorMap)
        }
      
   
    }
    
    public  var key : String? = nil
  
    public var ref : OpenAPISchemaReference?
    public var type : (any OpenAPIValidatableSchemaType)?
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

