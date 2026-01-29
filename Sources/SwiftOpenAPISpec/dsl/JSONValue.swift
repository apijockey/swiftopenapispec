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

import Foundation

public enum JSONValue: Equatable, Sendable {
    case object([String: JSONValue])
    case array([JSONValue])
    case string(String)
    case number(Double)
    case integer(Int)
    case boolean(Bool)
    case null
}

public extension JSONValue {
    
    enum Errors : LocalizedError    {
       case notReadable(String), notConvertible(String)
    }
    init(from v : [String:Any]) throws {
        var obj: [String: JSONValue] = [:]
        obj.reserveCapacity(v.count)
        for (k, val) in v {
                let jv = try JSONValue(from: val)
                obj[k] = jv
            
        }
        self = .object(obj)
    }
    init(from any: Any) throws  {
        switch any {
        case let v as String:
            self = .string(v)
        case let v as Int:
            self = .integer(v)
        case let v as Double:
            self = .number(v)
        case let v as Float:
            self = .number(Double(v))
        case let v as Bool:
            self = .boolean(v)
        case let v as [Any]:
            let arr = try v.compactMap { try JSONValue(from: $0) }
            guard arr.count == v.count else  {
                throw Self.Errors.notConvertible(v.debugDescription)
            }
            self = .array(arr)
        case let v as [String: Any]:
            var obj: [String: JSONValue] = [:]
            obj.reserveCapacity(v.count)
            for (k, val) in v {
                let jv = try JSONValue(from: val)
                obj[k] = jv
            }
            self = .object(obj)
        case Optional<Any>.none:
            self = .null
        default:
            throw Self.Errors.notConvertible(String(describing: any))
        }
    }
    init(string : String?) {
        guard let string = string else {
            self =  .null
            return
        }
        self = .string(string)
    }
    init(int : Int?) {
        guard let int = int else {
            self = .null
            return
        }
        self = .integer(int)
    }
    init(float : Float?) {
        guard let float = float else {
            self = .null
            return
        }
        self = .number(Double(float))
    }
    init(double : Double?) {
        guard let double = double else {
            self = .null
            return
        }
        self = .number(double)
    }
    init(bool : Bool?) {
        guard let bool = bool else {
            self = .null
            return
        }
        self = .boolean(bool)
    }
    init(_ any: Any?) throws {
        switch any {
        case let v as String:
            self = .string(v)
        case let v as Int:
            self = .integer(v)
        case let v as Double:
            self = .number(v)
        case let v as Float:
            self = .number(Double(v))
        case let v as Bool:
            self = .boolean(v)
        case let v as [Any]:
            let arr = try v.compactMap { try JSONValue(from: $0) }
            guard arr.count == v.count else {
                throw Self.Errors.notConvertible(v.debugDescription)
            }
            self = .array(arr)
        case let v as [String: Any]:
            var obj: [String: JSONValue] = [:]
            obj.reserveCapacity(v.count)
            for (k, val) in v {
                let jv = try JSONValue(from: val)
                obj[k] = jv
            }
            self = .object(obj)
        case Optional<Any>.none:
            self = .null
        default:
            throw Self.Errors.notConvertible(String(describing: any))
        }
    }
    init(_ string: String?) {
        guard let string = string else {
            self = .null
            return
        }
        self = .string(string)
        return
    }
}

// MARK: - Extractors for Swift primitive types

public extension JSONValue {
    var stringValue: String? {
        switch self {
        case .string(let s): return s
        case .integer(let i): return String(i)
        case .number(let d): return String(d)
        case .boolean(let b): return String(b)
        case .null: return nil
        case .array, .object: return nil
        }
    }
    
    var intValue: Int? {
        switch self {
        case .integer(let i): return i
        case .number(let d): return Int(exactly: d) ?? Int(d)
        case .string(let s): return Int(s)
        case .boolean(let b): return b ? 1 : 0
        case .null: return nil
        case .array, .object: return nil
        }
    }
    
    var doubleValue: Double? {
        switch self {
        case .number(let d): return d
        case .integer(let i): return Double(i)
        case .string(let s): return Double(s)
        case .boolean(let b): return b ? 1.0 : 0.0
        case .null: return nil
        case .array, .object: return nil
        }
    }
    
    var floatValue: Float? {
        doubleValue.map(Float.init)
    }
    
    var boolValue: Bool? {
        switch self {
        case .boolean(let b): return b
        case .integer(let i): return i != 0
        case .number(let d): return d != 0.0
        case .string(let s):
            switch s.lowercased() {
            case "true", "yes", "1": return true
            case "false", "no", "0": return false
            default: return nil
            }
        case .null: return nil
        case .array, .object: return nil
        }
    }
}
