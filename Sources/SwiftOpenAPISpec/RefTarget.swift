//
//  RefTarget.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 12.12.25.
//

import Foundation
struct RefTarget: Hashable {
    let url: URL
    let fragment: String // e.g. "#/components/schemas/User"
}


actor DocumentLoader {
    var objectCash: [URL: OpenAPIObject] = [:]
    public enum Errors : CustomStringConvertible, LocalizedError {
        public var description: String{
            switch self {
            case .unreadable(let name, let err): return "Fixture unreadable: \(name) (\(err))"
            case .notUTF8(let name): return "Fixture not UTF-8 encoded: \(name)"
            
            }
        }
        
        case unreadable(String, Error)
        case notUTF8(String)
        public var errorDescription: String? {
            return description
        }
    }
    
    public func load(from url: URL) async throws -> PointerNavigable {
        do {
            let data = try Data(contentsOf: url)
            guard let string = String(data: data, encoding: .utf8) else {
                throw Self.Errors.notUTF8(url.absoluteString)
            }
            let apiSpec = try OpenAPIObject.read(text: string, url:url.absoluteString )
            objectCash[url] = apiSpec
            return apiSpec
        } catch {
            throw Self.Errors.unreadable(url.absoluteString, error)
        }
    }
}

struct JSONPointerResolver {
    enum Errors :LocalizedError {
       case missingHash(String), missingSlash(String), externalReference(String)
        
        var errorDescription: String? {
            switch self {
            case .missingSlash(let s):
                    return "Fragment \(s) must start with '/'"
            case .missingHash(let s):
                return "Pointer \(s) must start with '#"
            case .externalReference(let string):
                return "reference in external file \(string)"
            }
        }
    }
    /// Max recursion depth to protect against cycles / bad inputs
    let maxDepth: Int = 64

    /// Load a document from disk/URL into your OpenAPIObject domain model.
    /// Replace with your real loader.
    let loadDocument: (URL) async throws -> any PointerNavigable

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
    func parseRef(_ ref: String, baseURL: URL) -> RefTarget {
        let parts = ref.split(separator: "#", maxSplits: 1, omittingEmptySubsequences: false)
        let filePart = String(parts.first ?? "")
        let fragmentPart = parts.count > 1 ? "#"+String(parts[1]) : "#"

        let targetURL: URL = filePart.isEmpty
            ? baseURL
            : baseURL.deletingLastPathComponent().appendingPathComponent(filePart)

        return RefTarget(url: targetURL, fragment: fragmentPart)
    }

    /// Resolve an OpenAPI fragment like "#/components/schemas/EventEnvelope"
    /// by walking segments using element(for:).
    func resolve(
        root: any PointerNavigable,
        fragment: String
    ) throws -> Any {
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
            do {
                // 1) Prefer domain navigation
                if let nav = current as? PointerNavigable {
                    if let next = try nav.element(for: seg) {
                        current = next
                        continue
                    }
                    throw NSError(domain: "PointerHarness", code: 3, userInfo: [NSLocalizedDescriptionKey: "Segment not found at \(traversed)"])
                }
                else if let nav = current as? [any KeyedElement] {
                    if let next = nav.element(for: seg) {
                        current = next
                        continue
                    }
                }
                else if let stringValue = current as? String{
                    return stringValue
                }
            }
            catch let error as JSONPointerResolver.Errors {
                switch error {
                case .externalReference(let s):
                    throw NSError(domain: "PointerHarness", code: 6, userInfo: [NSLocalizedDescriptionKey: "external files \(s) not yet supported"])
                default:
                    throw error
                }
            }
            catch {
                throw error
            }

            throw NSError(domain: "PointerHarness", code: 6, userInfo: [NSLocalizedDescriptionKey: "Type mismatch at \(traversed)"])
        }

        return current
    }

    /// Resolve a ref fully:
    /// - loads referenced doc if needed
    /// - resolves fragment within that doc
    /// - if result has "$ref" (as String), follow recursively
    func resolve(
        baseURL: URL,
        ref: String
    ) async throws -> Any {
        var visited = Set<RefTarget>()
        return try await resolveRefInternal(baseURL: baseURL, ref: ref, visited: &visited, depth: 0)
    }

    private func resolveRefInternal(
        baseURL: URL,
        ref: String,
        visited: inout Set<RefTarget>,
        depth: Int
    ) async throws -> Any {
        if depth > maxDepth {
            throw NSError(domain: "PointerHarness", code: 7, userInfo: [NSLocalizedDescriptionKey: "Max $ref depth exceeded"])
        }

        let target = parseRef(ref, baseURL: baseURL)
        if !visited.insert(target).inserted {
            throw NSError(domain: "PointerHarness", code: 8, userInfo: [NSLocalizedDescriptionKey: "Circular $ref detected: \(ref)"])
        }

        let doc = try await loadDocument(target.url)
        let resolved = try resolve(root: doc, fragment: target.fragment)

        // If resolved is a domain object that can yield "$ref", follow it
        if let nav = resolved as? PointerNavigable,
           let innerRef = try nav.element(for: "$ref") as? String {
            return try await resolveRefInternal(baseURL: target.url, ref: innerRef, visited: &visited, depth: depth + 1)
        }

        // Or if resolved is a raw dict
        if let dict = resolved as? [String: Any],
           let innerRef = dict["$ref"] as? String {
            return try await resolveRefInternal(baseURL: target.url, ref: innerRef, visited: &visited, depth: depth + 1)
        }

        return resolved
    }
}

