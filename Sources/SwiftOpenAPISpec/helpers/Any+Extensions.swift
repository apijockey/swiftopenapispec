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
//  Any+Extensions.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 30.12.25.
//

import Foundation


extension Any? {
    public  var stringifyValue : String {
        switch self {
        case let s as String:
            return s
        case let b as Bool:
            return String(b)
        case let i as Int:
            return String(i)
        case let i8 as Int8:
            return String(i8)
        case let i16 as Int16:
            return String(i16)
        case let i32 as Int32:
            return String(i32)
        case let i64 as Int64:
            return String(i64)
        case let u as UInt:
            return String(u)
        case let u8 as UInt8:
            return String(u8)
        case let u16 as UInt16:
            return String(u16)
        case let u32 as UInt32:
            return String(u32)
        case let u64 as UInt64:
            return String(u64)
        case let d as Double:
            return String(d)
        case let f as Float:
            return String(f)
        case nil:
            return "null"
            
        case let arr as [Any]:
            // Try to JSON-encode array
            if let data = try? JSONSerialization.data(withJSONObject: arr, options: []),
               let json = String(data: data, encoding: .utf8) {
                return json
            }
            return String(describing: arr)
            
        case let dict as [String: Any]:
            // Try to JSON-encode dictionary
            if let data = try? JSONSerialization.data(withJSONObject: dict, options: []),
               let json = String(data: data, encoding: .utf8) {
                return json
            }
            return String(describing: dict)
            
        default:
            return String(describing: self)
        }
        
    }
}
