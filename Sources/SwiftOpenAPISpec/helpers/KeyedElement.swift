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
//  KeyedElement.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 10.12.25.
//

import Foundation

// MARK: - Navigation


public enum NavigationResult : Equatable{
    public static func == (lhs: NavigationResult, rhs: NavigationResult) -> Bool {
        if case let .value(lhsValue) =  lhs,
           case let .value(rhsValue) = rhs  {
            return lhsValue == rhsValue
        }
        if case let .notFound(lhsString) =  lhs,
           case let .notFound(rhsString) = rhs  {
            return lhsString == rhsString
        }
        if case let .reference(lhsString) =  lhs,
           case let .reference(rhsString) = rhs  {
            return lhsString == rhsString
        }
        if case let .value(lhsString) =  lhs,
           case let .value(rhsString) = rhs  {
            return lhsString == rhsString
        }
        return false
    }
    
    case navigable(PointerNavigable?)
    // Elements must be both KeyedElement and PointerNavigable
    case navigableCollection([any KeyedElement & PointerNavigable])
    case searchableCollection([any KeyedElement])
    
    case notFound(String)
    case value(JSONValue?)
    case reference(String?)
}
public protocol PointerNavigable : Sendable {
    func element(for segmentName: String) throws -> NavigationResult
   
   
     
}
public protocol RefPointerNavigable : PointerNavigable {
    var ref : OpenAPISchemaReference? { get }
}


// MARK: - Core Protocols

public protocol KeyedElement : ThrowingHashMapInitiable {
    var key : String? { get set }
}

public typealias StringDictionary = [String: JSONValue]

// MARK: - Array helpers for KeyedElement


public extension Array where Element : KeyedElement {
    subscript (key key: String) -> Element? {
        return self.first(where: { $0.key == key })
    }
    func contains(name key: String) -> Bool {
        return self.contains(where: { $0.key == key })
    }
    func element(for segmentName: String) throws -> NavigationResult{
        let value = self.first { namedComponent in
            namedComponent.key == segmentName
        }
        
        let jsonValue = try JSONValue(value)
        return .value(jsonValue)
    }
}

extension Optional where Wrapped : RandomAccessCollection,  Wrapped.Element : PointerNavigable, Wrapped.Element : KeyedElement {
    public func element(for segmentName : String) throws -> NavigationResult{
        guard let array = self else {
            return .notFound(segmentName)
        }
        guard let element = array.first (where:{ element in
            element.key == segmentName
        }) else {
            return .notFound(segmentName)
        }
        return .navigable(element)
    }
}

extension Optional where Wrapped : RandomAccessCollection,   Wrapped.Element : KeyedElement {
    public func element(for segmentName : String) throws -> NavigationResult{
        guard let array = self else {
            return .notFound(segmentName)
        }
        guard let element = array.first (where:{ element in
            element.key == segmentName
        }) else {
            return .notFound(segmentName)
        }
        let value = try JSONValue(element)
        return .value(value)
    }
}

extension Array where Element : KeyedElement, Element : PointerNavigable {
    public func element(for segmentName : String) throws -> NavigationResult{
        guard let element = self.first (where:{ element in
            element.key == segmentName
        }) else {
            return .notFound(segmentName)
        }
        return .navigable(element)
    }
}

// Helper for existential arrays whose elements are both KeyedElement & PointerNavigable
public extension Array where Element == any KeyedElement & PointerNavigable {
    func element(for segmentName: String) -> NavigationResult {
        guard let element = self.first(where: { $0.key == segmentName }) else {
            return .notFound(segmentName)
        }
        return .navigable(element)
    }
}

/**A KeyedElement expects that the key Value is set from outside**/

// MARK: - Encoding to StringDictionary (for Yams)

public protocol ThrowingHashMapEncodable {
    /// Build a YAML/JSON-compatible dictionary representation
    func toDictionary() throws -> StringDictionary
}

// Default container encoders and helpers
public enum HashMapEncodingError: Error, CustomStringConvertible {
    case invalidValue(String, JSONValue)
    case missingKey(String)
    case unsupportedType(String)

    public var description: String {
        switch self {
        case .invalidValue(let key, let value):
            return "Invalid value for key '\(key)': \(type(of: value))"
        case .missingKey(let key):
            return "Missing required key: \(key)"
        case .unsupportedType(let what):
            return "Unsupported type for encoding: \(what)"
        }
    }
}

//// MARK: - Utilities for building dictionaries
//
//public extension ThrowingHashMapEncodable {
//    ...
//}
//
