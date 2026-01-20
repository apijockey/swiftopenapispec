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
//  Created by Patric Dubois on 15.12.25.
//

import Foundation



public protocol JSONPointerResolving {
    func parseRef(_ ref: String) async -> RefTarget
    mutating func resolve(ref: String) async throws -> Any
}

public struct JSONPointerResolver : JSONPointerResolving {
   
    /// Resolve a ref fully:
    /// - loads referenced doc if needed
    /// - resolves fragment within that doc
    /// - if result has "$ref" (as String), follow recursively
    public mutating func resolve(
        
        ref: String
    ) async throws -> Any {
        var visited = Set<RefTarget>()
        return try await resolveRefInternal( ref: ref, visited: &visited, depth: 0)
    }
    
    static let internalReferencePrefix:String = "#"
    public init(baseURL : URL,loadDocument: @escaping (URL) async throws -> any PointerNavigable) {
        self.loadDocument = loadDocument
        self.baseURL = baseURL
        self.currentURL = baseURL
    }
    public enum Errors :LocalizedError {
        case missingHash(String), missingSlash(String), externalReference(String), internalReference(String)
        
        public var errorDescription: String? {
            switch self {
            case .missingSlash(let s):
                return "Fragment \(s) muss mit '/' beginnen"
            case .missingHash(let s):
                return "Pointer \(s) muss mit '# beginnen"
            case .externalReference(let string):
                return "reference in external file \(string)"
            case .internalReference(let string):
                return "reference in file \(string)"
            }
        }
    }
    /// Max recursion depth to protect against cycles / bad inputs
    let maxDepth: Int = 64
    
    /// Load a document from disk/URL into your OpenAPISpecification domain model.
    /// Replace with your real loader.
    let loadDocument: (URL) async throws -> any PointerNavigable
    var baseURL : URL
    var currentURL : URL
    
    // RFC 6901 decode: "~1" -> "/", "~0" -> "~" (order matters)
    static func decodePointerSegment(_ segment: String) -> String {
        segment
            .replacingOccurrences(of: "~1", with: "/")
            .replacingOccurrences(of: "~0", with: "~")
    }
    
    /// Parse a ref string like:
    ///  - "#/components/schemas/X"
    ///  - "./ext-components.yaml#/components/schemas/X"
    /// Returns absolute URL + fragment (fragment includes leading '#', may be "#")
    public func parseRef(_ ref: String) async -> RefTarget {
        let parts = ref.split(separator: "#", maxSplits: 1, omittingEmptySubsequences: false)
        let filePart = String(parts.first ?? "")
        let fragmentPart = parts.count > 1 ? "#"+String(parts[1]) : "#"
        
        let targetURL: URL = filePart.isEmpty
        ? currentURL
        : currentURL.deletingLastPathComponent().appendingPathComponent(filePart)
        
        return RefTarget(url: targetURL, fragment: fragmentPart)
    }
    
    /// Resolve an OpenAPI fragment like "#/components/schemas/EventEnvelope"
    /// by walking segments using element(for:).
    public mutating func resolve(
        root: any PointerNavigable,
        fragment: String,
        _ depth: Int = 0
    ) async throws -> Any {
        // Normalize: "#" -> root; "#/a/b" -> "/a/b"
        if fragment == "#" || fragment.isEmpty {
            return root
        }
        guard fragment.hasPrefix("#") else {
            throw Self.Errors.missingHash(fragment)
        }
        
        let pointer = String(fragment.dropFirst()) // remove leading '#'
        if pointer.isEmpty { return root }
        guard pointer.hasPrefix("/") else {
            throw Self.Errors.missingSlash(pointer)
        }
        
        let rawSegments = pointer.dropFirst().split(separator: "/").map(String.init)
        let segments = rawSegments.map(JSONPointerResolver.decodePointerSegment)
        
        var current: Any = root
        var traversed = ""
         
        for seg in segments {
            
            traversed += "/\(seg)"
            if let stringValue = current as? String{
                return stringValue
            }
            if let nav = current as? [any KeyedElement] {
                if let next = nav.element(for: seg) {
                    current = next
                    if traversed != pointer {
                        continue
                    }
                    
                }
                else {
                    throw Validator.Errors.invalidPointer( "Segment '\(seg)' not found at '\(fragment)'")
                    
                }
            }
            //found the right element, now continue to resolve 
            // try to resolve References before accessing their properties
            if let currentNavigatable = current as? PointerNavigable{
                if seg == "$ref" {
                    if let element = try currentNavigatable.element(for: seg) {
                        return element
                    }
                }
                else if let reference =  currentNavigatable.ref,
                        let ref = reference.reference{
                    current = try await resolve(ref: ref) //recurse
                    
                }
            }
            //default ... walk through the object graph
            if traversed == pointer {
                return current
            }
            
            if let currentNavigatable = current as? PointerNavigable{
                if let next = try currentNavigatable.element(for: seg) {
                    current = next
                    continue
                }
                // If resolved is a domain object that can yield "$ref", follow it
                throw Validator.Errors.invalidPointer( "Segment '\(seg)' not found at '\(fragment)'")
                
            }
        }
        return current
    }
    
  
    
    private mutating func resolveRefInternal(
        
        ref: String,
        visited: inout Set<RefTarget>,
        depth: Int
    ) async throws -> Any {
        if depth > maxDepth {
            throw Validator.Errors.maxRecursion("Max $ref depths exceeded for 'ref'", depth)
            
        }
        
        let target = await parseRef(ref)
        currentURL = target.url
        if !visited.insert(target).inserted {
            throw Validator.Errors.invalidPointer("Circular $ref detected: '\(ref)' ")
            
        }
        
        let doc = try await loadDocument(target.url)
        let resolved = try await resolve(root: doc, fragment: target.fragment)
      
//        // Or if resolved is a raw dict
//        if let dict = resolved as? PointerNavigable,
//           let innerRef = try dict.element(for: "$ref") as? String {
//                return try await resolveRefInternal(ref: innerRef, visited: &visited, depth: depth + 1)
//        }
//        
        return resolved
    }
}
