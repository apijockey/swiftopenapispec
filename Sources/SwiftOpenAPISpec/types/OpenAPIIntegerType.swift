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

/*
 * Copyright 2025 
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
//  OpenAPIIntegerType.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 07.12.25.
//


public struct OpenAPIIntegerType :  OpenAPIValidatableSchemaType, ThrowingHashMapInitiable, PointerNavigable  {
    public func element(for segmentName: String) throws -> Any? {
        switch segmentName {
            case Self.TYPE_KEY : return type
            case Self.FORMAT_KEY : return format
            case Self.DEFAULT_KEY :return defaultValue
            case Self.MULTIPLEOF_KEY :return multipleOf
            case Self.MINIMUM_KEY: return minimum
            case Self.MAXIMUM_KEY :return maximum
            case Self.EXCLUSIVEMINIMUM_KEY : return exclusiveMinimum
            case Self.EXCLUSIVEMAXIMUM_KEY : return exclusiveMaximum
            default:
                throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIIntegerType", segmentName)
        }
    }
    
    public var ref: OpenAPISchemaReference? { nil}
    
    public func validate() throws {
        
    }
    public static let FORMAT_KEY : String = "format"
    public static let TYPE_KEY = "type"
    public static let DEFAULT_KEY = "default"
    public static let MULTIPLEOF_KEY = "multipleOf"
    public static let MINIMUM_KEY = "minimum"
    public static let MAXIMUM_KEY = "maximum"
    public static let EXCLUSIVEMINIMUM_KEY = "exclusiveMinimum"
    public static let EXCLUSIVEMAXIMUM_KEY = "exclusiveMaximum"
   
    public init(_ map: [String : Any]) throws {
        self.type = map[Self.TYPE_KEY] as? String ?? DataType.integer.rawValue
        self.defaultValue = map[Self.DEFAULT_KEY] as? Int
        self.multipleOf =  map[Self.MULTIPLEOF_KEY] as? Int
        self.maximum =  map[Self.MAXIMUM_KEY]  as? Int
        self.exclusiveMaximum =  map[Self.EXCLUSIVEMAXIMUM_KEY]  as? Int
        self.minimum =  map[Self.MINIMUM_KEY]  as? Int
        self.exclusiveMinimum =  map[Self.EXCLUSIVEMINIMUM_KEY]  as? Int
        self.format = map.readIfPresent(Self.FORMAT_KEY, String.self)
    }
    public let type :String
    public let multipleOf : Int?
    public let defaultValue : Int?
    public let maximum : Int?
    public let exclusiveMaximum : Int?
    public let minimum : Int?
    public let exclusiveMinimum : Int?
    public var format : String?
   
    
}
