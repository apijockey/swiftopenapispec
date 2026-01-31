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
    mutating func resolve(ref: String) async throws -> NavigationResult
}

public struct JSONPointerResolver : JSONPointerResolving {
   
    /// Resolve a ref fully:
    /// - loads referenced doc if needed
    /// - resolves fragment within that doc
    /// - if result has "$ref" (as String), follow recursively
    public mutating func resolve(
        
        ref: String
    ) async throws -> NavigationResult {
        var visited = Set<RefTarget>()
        return try await resolveRefInternal( ref: ref, visited: &visited, depth: 0)
    }
    
    static let internalReferencePrefix:String = "#"
    public init(baseURL : URL,loadDocument: @escaping (URL) async throws -> OpenAPISpecification) {
        self.loadDocument = loadDocument
        self.baseURL = baseURL
        self.currentURL = baseURL
    }
    public enum Errors :LocalizedError {
        case missingHash(String), missingSlash(String), externalReference(String), internalReference(String), notFound(String,String), invalidPointer(String)
        
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
            case .notFound(let segment, let traversed):
                return "segment \(segment) not found in \(traversed)"
            case .invalidPointer(let refString):
                return "JSONPointer not found \(refString)"
            }
        }
    }
    /// Max recursion depth to protect against cycles / bad inputs
    let maxDepth: Int = 64
    
    /// Load a document from disk/URL into your OpenAPISpecification domain model.
    /// Replace with your real loader.
    let loadDocument: (URL) async throws -> OpenAPISpecification
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
        root: PointerNavigable,
        fragment: String,
        _ depth: Int = 0
    ) async throws -> NavigationResult {
        // Normalize: "#" -> root; "#/a/b" -> "/a/b"
        if fragment == "#" || fragment.isEmpty {
            let value = try JSONValue(root)
            return .value(value)
        }
        guard fragment.hasPrefix("#") else {
            throw Self.Errors.missingHash(fragment)
        }
        
        let pointer = String(fragment.dropFirst()) // remove leading '#'
        if pointer.isEmpty {
            let value = try JSONValue(root)
            return .value(value) }
        guard pointer.hasPrefix("/") else {
            throw Self.Errors.missingSlash(pointer)
        }
        
        let rawSegments = pointer.dropFirst().split(separator: "/").map(String.init)
        let segments = rawSegments.map(JSONPointerResolver.decodePointerSegment)
        
        var current: NavigationResult = .navigable(root)
        var traversed = ""
        
        for seg in segments {
            
            
            switch  current {
            case .navigable(let currentPointerNavigable):
                guard let currentPointerNavigable = currentPointerNavigable else {
                    throw Self.Errors.notFound(seg, traversed)
                }
                let next = try currentPointerNavigable.element(for: seg)
               
                if case .reference(let reference) = next {
                    if traversed.appending("/").appending(seg) == pointer,
                       seg == "$ref" {
                        return next
                    }
                    else if let reference = reference {
                        let resolve = try await resolve(ref: reference)
                        current = resolve
                        traversed += "/\(seg)"
                        continue
                        
                    }
                }
                else {
                    current = next
                    traversed += "/\(seg)"
                    continue
                }
                
            case .notFound:
                throw Self.Errors.notFound(seg, traversed)
            case .value(let jSONValue):
                traversed += "/\(seg)"
                return .value(jSONValue)
                
            case .navigableCollection(let navigableCollection):
                
                let next = navigableCollection.element(for: seg)
                if case .reference(let reference) = next {
                    if let reference = reference {
                        let resolve = try await resolve(ref: reference)
                        current = resolve
                        traversed += "/\(seg)"
                        continue
                        
                    }
                }
                else {
                    current = next
                    traversed += "/\(seg)"
                    continue
                }
            case .searchableCollection(let collection):
                let value = try JSONValue(collection.first(where: { $0.key == seg }))
                return .value(value)
                
                
            case .reference(let reference):
                if let reference = reference {
                    let resolve = try await resolve(ref: reference)
                    current = resolve
                    traversed += "/\(seg)"
                    
                }
            }
        }
        return current
    }
    
    private mutating func resolveRefInternal(
        
        ref: String,
        visited: inout Set<RefTarget>,
        depth: Int
    ) async throws -> NavigationResult {
        if depth > maxDepth {
            throw Validator.Errors.maxRecursion("Max $ref depths exceeded for 'ref'", depth)
            
        }
        
        let target = await parseRef(ref)
        currentURL = target.url
        if !visited.insert(target).inserted {
            throw Validator.Errors.invalidPointer("Circular $ref detected: '\(ref)' ")
            
        }
        
        let specification = try await loadDocument(target.url)
        
        let resolved = try await resolve(root: specification, fragment: target.fragment)
        return resolved
        
    }
}
