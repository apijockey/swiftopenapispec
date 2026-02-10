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
       case notReadable(String), notConvertible([Diagnostic])
    }
    init(from v : [String:Any], diagnostics : inout [Diagnostic]) throws {
        diagnostics.append(Diagnostic(severity: .info, code: .debugTrace, message: "_ any: Any \(String(describing: v))", pointer: "(diagnostics.count)", rule: "JSONValueConvertible"))
        var obj: [String: JSONValue] = [:]
        obj.reserveCapacity(v.count)
        for (k, val) in v {
                let jv = try JSONValue(from: val, diagnostics : &diagnostics)
                obj[k] = jv
            
        }
        self = .object(obj)
    }
    init(from any: Any) throws  {
    var diagnostics: [Diagnostic] = []
        try self.init(from: any, diagnostics: &diagnostics)
    }
    init(from any: Any, diagnostics : inout [Diagnostic]) throws  {
        diagnostics.append(Diagnostic(severity: .info, code: .debugTrace, message: "_ any: Any \(String(describing: any))", pointer: "(diagnostics.count)", rule: "JSONValueConvertible"))
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
            let arr = try v.compactMap { try JSONValue(from: $0,diagnostics : &diagnostics) }
            guard arr.count == v.count else  {
                throw Self.Errors.notConvertible(diagnostics)
            }
            self = .array(arr)
        case let v as [String: Any]:
            var obj: [String: JSONValue] = [:]
            obj.reserveCapacity(v.count)
            for (k, val) in v {
                let jv = try JSONValue(from: val,diagnostics : &diagnostics)
                obj[k] = jv
            }
            self = .object(obj)
        case Optional<Any>.none:
            self = .null
        default:
            self = .null
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
        var diagnostics: [Diagnostic] = []
        try self.init(any, diagnostics: &diagnostics)
    }
    init(_ any: Any?,diagnostics : inout [Diagnostic]) throws {
        diagnostics.append(Diagnostic(severity: .info, code: .debugTrace, message: "_ any: Any? \(any.debugDescription)", pointer: "(diagnostics.count)", rule: "JSONValueConvertible"))
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
            let arr = try v.compactMap { try JSONValue(from: $0,diagnostics : &diagnostics) }
            guard arr.count == v.count else {
                throw Self.Errors.notConvertible(diagnostics)
            }
            self = .array(arr)
        case let v as [String: Any]:
            var obj: [String: JSONValue] = [:]
            obj.reserveCapacity(v.count)
            for (k, val) in v {
                let jv = try JSONValue(from: val,diagnostics : &diagnostics)
                obj[k] = jv
            }
            self = .object(obj)
        case Optional<Any>.none:
            self = .null
            
        default:
            throw Self.Errors.notConvertible(diagnostics)
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
    
    // MARK: - New: Initializers for existential KeyedElement values
    
    // Converts an existential KeyedElement by asking it to provide a JSONValue via JSONValueConvertible.
    // If value is nil, produce .null.
    init(_ value: (any KeyedElement)?) throws {
        guard let value else {
            self = .null
            return
        }
        try self.init(value)
    }
    
   
}

// MARK: - Extractors for Swift primitive types

extension JSONValue : CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .string(let s): return "string(\(s))"
        case .integer(let i): return "integer(\(String(i)))"
        case .number(let d): return  "number(\(String(d)))"
        case .boolean(let b): return "boolean(\(String(b)))"
        case .null: return "null"
        case .array: return "array"
        case .object: return "object"
        }
    }
    
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
    
    
    var objectValue: [String: JSONValue]? {
            guard case let .object(value) = self else { return nil }
            return value
        }

        var arrayValue: [JSONValue]? {
            guard case let .array(value) = self else { return nil }
            return value
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
    var numberValue: Double? {
        switch self {
            case .integer(let i): return Double(i)
            case .number(let d): return Double(d)
            case .string(let s): return Double(s)
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
    var isNull: Bool {
            guard case .null = self else { return false }
            return true
        }
}
