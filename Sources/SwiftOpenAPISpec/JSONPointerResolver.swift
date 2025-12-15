//
//  RefTarget.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 12.12.25.
//

import Foundation





public struct JSONPointerResolver {
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
                return "Fragment \(s) must start with '/'"
            case .missingHash(let s):
                return "Pointer \(s) must start with '#"
            case .externalReference(let string):
                return "reference in external file \(string)"
            case .internalReference(let string):
                return "reference in file \(string)"
            }
        }
    }
    /// Max recursion depth to protect against cycles / bad inputs
    let maxDepth: Int = 64
    
    /// Load a document from disk/URL into your OpenAPIObject domain model.
    /// Replace with your real loader.
    let loadDocument: (URL) async throws -> any PointerNavigable
    var baseURL : URL
    var currentURL : URL
    
    // RFC 6901 decode: "~1" -> "/", "~0" -> "~" (order matters)
    func decodePointerSegment(_ segment: String) -> String {
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
    mutating func resolve(
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
        let segments = rawSegments.map(decodePointerSegment)
        
        var current: Any = root
        var traversed = ""
        
        for seg in segments {
            traversed += "/\(seg)"
            
                // 1) Prefer domain navigation
            if let currentNavigatable = current as? PointerNavigable{
                if seg == "$ref" {
                    return try currentNavigatable.element(for: seg)
                }
                else if currentNavigatable.hasFilledRef,
                        let ref = currentNavigatable.ref{
                    current = try await resolve(ref: ref)
                    continue
                }
                //KLÄREN, waum
                else if let next = try currentNavigatable.element(for: seg) {
                    current = next
                    continue
                }
                // If resolved is a domain object that can yield "$ref", follow it
                throw NSError(domain: "PointerHarness", code: 3, userInfo: [NSLocalizedDescriptionKey: "Segment not found at \(traversed)"])
            }
            if let nav = current as? [any KeyedElement] {
                if let next = nav.element(for: seg) {
                    current = next
                    continue
                }
            }
            if let stringValue = current as? String{
                return stringValue
            }
            
            
        }
        
        return current
    }
    
    /// Resolve a ref fully:
    /// - loads referenced doc if needed
    /// - resolves fragment within that doc
    /// - if result has "$ref" (as String), follow recursively
    mutating func resolve(
        
        ref: String
    ) async throws -> Any {
        var visited = Set<RefTarget>()
        return try await resolveRefInternal( ref: ref, visited: &visited, depth: 0)
    }
    
    private mutating func resolveRefInternal(
        
        ref: String,
        visited: inout Set<RefTarget>,
        depth: Int
    ) async throws -> Any {
        if depth > maxDepth {
            throw NSError(domain: "PointerHarness", code: 7, userInfo: [NSLocalizedDescriptionKey: "Max $ref depth exceeded"])
        }
        
        let target = await parseRef(ref)
        currentURL = target.url
        if !visited.insert(target).inserted {
            throw NSError(domain: "PointerHarness", code: 8, userInfo: [NSLocalizedDescriptionKey: "Circular $ref detected: \(ref)"])
        }
        
        let doc = try await loadDocument(target.url)
        let resolved = try await resolve(root: doc, fragment: target.fragment)
      
        // Or if resolved is a raw dict
        if let dict = resolved as? PointerNavigable,
           let innerRef = try dict.element(for: "$ref") as? String {
                return try await resolveRefInternal(ref: innerRef, visited: &visited, depth: depth + 1)
        }
        
        return resolved
    }
}

