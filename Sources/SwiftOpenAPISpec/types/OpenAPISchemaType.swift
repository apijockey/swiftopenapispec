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
//  OpenAPIDefaultSchemaType.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 07.12.25.
//


public struct OpenAPISchemaType : OpenAPIValidatableSchemaType {
    public static let TYPE_KEY = "type"
    public init(_ map: [String : Any]) throws {
        self.type = map[Self.TYPE_KEY] as? String
    }
    
    public func validate() throws {
        
    }
    public static func validatableType(_ string : String)  -> (any OpenAPIValidatableSchemaType.Type)? {
        switch string {
            case "array" : return OpenAPIArrayType.self
            case "integer" : return OpenAPIIntegerType.self
            case "number" : return OpenAPIDoubleType.self
            case "string" : return OpenAPIStringType.self
            case "object" : return OpenAPIObjectType.self
            case "null": return OpenAPINullType.self
            case OpenAPISchemaReference.REF_KEY  : return OpenAPISchemaReference.self
            default:
                return nil
        }
    }
    public let type : String?
  
}
public extension Array where Element == OpenAPISchemaType   {
    init(_ map: [AnyHashable : Any]) throws {
        self.init()
       print(map)
    }
}

public extension Array where Element == Any   {
    func asValidatableSchemaType() throws -> [(any OpenAPIValidatableSchemaType)] {
        var map : [any OpenAPIValidatableSchemaType] = []
            for element in self {
                if let dict = element as? [String : Any],
                   let firstKey = dict.keys.first,
                   let type = OpenAPISchemaType.validatableType(firstKey)             {
                    let element = try type.init(dict)
                    map.append(element)
                }
                else  if let dict = element as? [String : Any],
                    let type = dict[OpenAPISchemaType.TYPE_KEY] as? String,
                        let typeInfo = OpenAPISchemaType.validatableType(type) {
                        let validatableType = try typeInfo.init(dict)
                        map.append(validatableType)
                }
        }
        return map
    }
}
