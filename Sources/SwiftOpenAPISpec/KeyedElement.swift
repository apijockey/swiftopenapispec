//
//  KeyedElement.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 10.12.25.
//

import Foundation

// MARK: - Navigation

protocol PointerNavigable {
    func element(for segmentName: String) throws -> Any?
}

// MARK: - Core Protocols

public protocol KeyedElement : ThrowingHashMapInitiable {
    var key : String? { get set }
}

public typealias StringDictionary = [String: Any]

// MARK: - Array helpers for KeyedElement

public extension Array where Element : KeyedElement {
    subscript (key key: String) -> Element? {
        return self.first(where: { $0.key == key })
    }
    func contains(name key: String) -> Bool {
        return self.contains(where: { $0.key == key })
    }
    func element(for segmentName: String) -> Element? {
        self.first { namedComponent in
            namedComponent.key == segmentName
        }
    }
}

// Support arrays whose static type is [any KeyedElement] (existential)
public extension Array where Element == any KeyedElement {
    func element(for segmentName: String) -> (any KeyedElement)? {
        self.first { namedComponent in
            namedComponent.key == segmentName
        }
    }
}

extension KeyedElement {
    public static func element(for segmentName : String) throws -> Any? {
        nil
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
    case invalidValue(String, Any)
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

// MARK: - Utilities for building dictionaries

public extension ThrowingHashMapEncodable {

    // Encode primitive or JSON-compatible value into a map if present
    @discardableResult
    func encodeKey(_ key: String, value: Any?, into dict: inout StringDictionary) throws -> Bool {
        guard let value else { return false }
        if isJSONCompatible(value) {
            dict[key] = value
            return true
        } else {
            throw HashMapEncodingError.invalidValue(key, value)
        }
    }

    // Encode another ThrowingHashMapEncodable under key
    @discardableResult
    func encodeKey(_ key: String, encodable: (any ThrowingHashMapEncodable)?, into dict: inout StringDictionary) throws -> Bool {
        guard let encodable else { return false }
        dict[key] = try encodable.toDictionary()
        return true
    }

    // Encode optional encodable
    @discardableResult
    func encodeKeyOptional(_ key: String, encodable: (any ThrowingHashMapEncodable)?, into dict: inout StringDictionary) throws -> Bool {
        try encodeKey(key, encodable: encodable, into: &dict)
    }

    // Encode a list of encodables as an array of dictionaries
    @discardableResult
    func encodeList<T: ThrowingHashMapEncodable>(_ key: String, from list: [T]?, into dict: inout StringDictionary) throws -> Bool {
        guard let list, !list.isEmpty else { return false }
        dict[key] = try list.map { try $0.toDictionary() }
        return true
    }

    // Encode a list of primitives / JSON-compatible
    @discardableResult
    func encodePrimitiveList<T>(_ key: String, from list: [T]?, into dict: inout StringDictionary) throws -> Bool {
        guard let list, !list.isEmpty else { return false }
        // best-effort: ensure items are JSON-compatible
        for item in list {
            guard isJSONCompatible(item) else {
                throw HashMapEncodingError.invalidValue(key, item)
            }
        }
        dict[key] = list
        return true
    }

    // Encode a map from an array of KeyedElement by using their key as dictionary key and each element's toDictionary() as value.
    @discardableResult
    func encodeMapFromKeyedArray<T>(_ key: String, array: [T]?, into dict: inout StringDictionary) throws -> Bool where T: KeyedElement & ThrowingHashMapEncodable {
        guard let array, !array.isEmpty else { return false }
        var result: StringDictionary = [:]
        for element in array {
            guard let name = element.key, !name.isEmpty else {
                throw HashMapEncodingError.missingKey("\(key).<element>.key")
            }
            result[name] = try element.toDictionary()
        }
        dict[key] = result
        return true
    }

    // Encode a simple map [String: ThrowingHashMapEncodable]
    @discardableResult
    func encodeMap<T>(_ key: String, map: [String: T]?, into dict: inout StringDictionary) throws -> Bool where T: ThrowingHashMapEncodable {
        guard let map, !map.isEmpty else { return false }
        var result: StringDictionary = [:]
        for (k, v) in map {
            result[k] = try v.toDictionary()
        }
        dict[key] = result
        return true
    }

    // Encode vendor extensions from your OpenAPIExtension model into x-* dictionary entries on the same level.
    // The input is [OpenAPIExtension]; we place each under its own x-* key either as a primitive or dictionary.
    func encodeExtensions(_ extensions: [OpenAPIExtension]?, into dict: inout StringDictionary) {
        guard let extensions, !extensions.isEmpty else { return }
        for ext in extensions {
            guard let name = ext.key, name.hasPrefix("x-") else { continue }
            if let simple = ext.simpleExtensionValue {
                dict[name] = simple
            } else if let structured = ext.structuredExtension?.properties {
                dict[name] = structured // [String: String] already JSON-compatible
            }
        }
    }

    // Helper: check if a value is JSON-compatible (String, Number, Bool, Null, [Any], [String: Any] with recursively compatible contents)
    func isJSONCompatible(_ value: Any) -> Bool {
        switch value {
        case is NSNull, is String, is Int, is Int8, is Int16, is Int32, is Int64, is UInt, is UInt8, is UInt16, is UInt32, is UInt64, is Double, is Float, is Bool:
            return true
        case let arr as [Any]:
            return arr.allSatisfy { isJSONCompatible($0) }
        case let dict as [String: Any]:
            return dict.values.allSatisfy { isJSONCompatible($0) }
        default:
            return false
        }
    }
}

