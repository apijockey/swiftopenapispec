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
//  File.swift
//
//
//  Created by Patric Dubois on 26.03.24.
//

import Foundation

public struct OpenAPIMediaType :  KeyedElement , PointerNavigable,OpenAPISchemaReferenceable {
    public static let SCHEMA_KEY = "schema"
    public static let ITEM_SCHEMA_KEY = "itemSchema"
    public static let EXAMPLES_KEY = "examples"
    public static let EXAMPLE_KEY = "example"
    public static let ENCODING_KEY = "encoding"
    public static let PREFIX_ENCODING_KEY = "prefixEncoding"
    public static let ITEM_ENCODING_KEY = "itemEncoding"
    public static let EXTENSIONS_KEY = "extensions"
    public var key : String?
    public init(_ map: [String : Any]) throws {
        if let ref  =  try OpenAPISchemaReference.initReference(from: (map)) {
            self.ref = ref
            return
        }
            if let schemaMap = map[Self.SCHEMA_KEY] as? StringDictionary {
                self.schema  = try OpenAPISchema(schemaMap)
            }
            if let schemaMap = map[Self.ITEM_SCHEMA_KEY] as? StringDictionary {
                self.schema  = try OpenAPISchema(schemaMap)
            }
             
            
            if let examplesMap  = map[Self.EXAMPLES_KEY]  as? StringDictionary{
                self.examples = try KeyedElementList.map(examplesMap)
            }
            if let subMap = map[Self.ENCODING_KEY] as? StringDictionary {
                encoding = try KeyedElementList<OpenAPIEncoding>.map(subMap)
            }
            if let subMap = map[Self.PREFIX_ENCODING_KEY] as? StringDictionary {
                prefixEncoding = try KeyedElementList<OpenAPIEncoding>.map(subMap)
            }
            if let subMap = map[Self.PREFIX_ENCODING_KEY] as? StringDictionary {
                itemEncoding = try KeyedElementList<OpenAPIEncoding>.map(subMap)
            }
       
    }
    
    public func element(for segmentName: String) throws -> Any? {
        switch segmentName {
        case Self.SCHEMA_KEY:
            return self.schema
        case Self.EXAMPLES_KEY:
            return self.examples
        case Self.ENCODING_KEY: return encoding
        case Self.PREFIX_ENCODING_KEY: return prefixEncoding
        case Self.ITEM_ENCODING_KEY: return itemEncoding
        case OpenAPISchemaReference.REF_KEY: return ref
        default:
            if self.key == segmentName { return self.schema }
            throw OpenAPISpecification.Errors.unsupportedSegment("OpenAPIMediaType", segmentName)
        }
    }
    public var schema : OpenAPISchema? = nil
    public var itemSchema : OpenAPISchema? = nil
    public var examples : [OpenAPIExample] = []
   
    public var encoding :[OpenAPIEncoding]? = nil
    public var prefixEncoding :[OpenAPIEncoding]? = nil
    public var itemEncoding :[OpenAPIEncoding]? = nil
    public var ref : OpenAPISchemaReference? = nil
    //ENCODING
}

