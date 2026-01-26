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
    init?(from any: Any) {
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
            let arr = v.compactMap { JSONValue(from: $0) }
            guard arr.count == v.count else { return nil }
            self = .array(arr)
        case let v as [String: Any]:
            var obj: [String: JSONValue] = [:]
            obj.reserveCapacity(v.count)
            for (k, val) in v {
                guard let jv = JSONValue(from: val) else { return nil }
                obj[k] = jv
            }
            self = .object(obj)
        case Optional<Any>.none:
            self = .null
        default:
            return nil
        }
    }
    init?(_ any: Any?) {
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
            let arr = v.compactMap { JSONValue(from: $0) }
            guard arr.count == v.count else { return nil }
            self = .array(arr)
        case let v as [String: Any]:
            var obj: [String: JSONValue] = [:]
            obj.reserveCapacity(v.count)
            for (k, val) in v {
                guard let jv = JSONValue(from: val) else { return nil }
                obj[k] = jv
            }
            self = .object(obj)
        case Optional<Any>.none:
            self = .null
        default:
            return nil
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
