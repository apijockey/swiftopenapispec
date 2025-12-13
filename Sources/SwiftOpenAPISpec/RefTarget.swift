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

struct JSONPointerResolver {
    /// Max recursion depth to protect against cycles / bad inputs
    let maxDepth: Int = 64

    /// Load a document from disk/URL into your OpenAPIObject domain model.
    /// Replace with your real loader.
    let loadDocument: (URL) throws -> any PointerNavigable

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
            throw NSError(domain: "PointerHarness", code: 1, userInfo: [NSLocalizedDescriptionKey: "Fragment must start with #"])
        }

        let pointer = String(fragment.dropFirst()) // remove leading '#'
        if pointer.isEmpty { return root }
        guard pointer.hasPrefix("/") else {
            throw NSError(domain: "PointerHarness", code: 2, userInfo: [NSLocalizedDescriptionKey: "Pointer must start with /"])
        }

        let rawSegments = pointer.dropFirst().split(separator: "/").map(String.init)
        let segments = rawSegments.map(decodePointerSegment)

        var current: Any = root
        var traversed = ""

        for seg in segments {
            traversed += "/\(seg)"

            // 1) Prefer domain navigation
            if let nav = current as? PointerNavigable {
                if let next = try nav.element(for: seg) {
                    current = next
                    continue
                }
                throw NSError(domain: "PointerHarness", code: 3, userInfo: [NSLocalizedDescriptionKey: "Segment not found at \(traversed)"])
            }

            // 2) Fallback for common container types if your domain returns raw containers sometimes
            if let dict = current as? [String: Any] {
                guard let next = dict[seg] else {
                    throw NSError(domain: "PointerHarness", code: 4, userInfo: [NSLocalizedDescriptionKey: "Key not found at \(traversed)"])
                }
                current = next
                continue
            }

            if let arr = current as? [Any] {
                guard let idx = Int(seg), idx >= 0, idx < arr.count else {
                    throw NSError(domain: "PointerHarness", code: 5, userInfo: [NSLocalizedDescriptionKey: "Index not found at \(traversed)"])
                }
                current = arr[idx]
                continue
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
    ) throws -> Any {
        var visited = Set<RefTarget>()
        return try resolveRefInternal(baseURL: baseURL, ref: ref, visited: &visited, depth: 0)
    }

    private func resolveRefInternal(
        baseURL: URL,
        ref: String,
        visited: inout Set<RefTarget>,
        depth: Int
    ) throws -> Any {
        if depth > maxDepth {
            throw NSError(domain: "PointerHarness", code: 7, userInfo: [NSLocalizedDescriptionKey: "Max $ref depth exceeded"])
        }

        let target = parseRef(ref, baseURL: baseURL)
        if !visited.insert(target).inserted {
            throw NSError(domain: "PointerHarness", code: 8, userInfo: [NSLocalizedDescriptionKey: "Circular $ref detected: \(ref)"])
        }

        let doc = try loadDocument(target.url)
        let resolved = try resolve(root: doc, fragment: target.fragment)

        // If resolved is a domain object that can yield "$ref", follow it
        if let nav = resolved as? PointerNavigable,
           let innerRef = try nav.element(for: "$ref") as? String {
            return try resolveRefInternal(baseURL: target.url, ref: innerRef, visited: &visited, depth: depth + 1)
        }

        // Or if resolved is a raw dict
        if let dict = resolved as? [String: Any],
           let innerRef = dict["$ref"] as? String {
            return try resolveRefInternal(baseURL: target.url, ref: innerRef, visited: &visited, depth: depth + 1)
        }

        return resolved
    }
}
