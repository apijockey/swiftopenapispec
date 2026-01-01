//
//  SwiftOpenAPICLIError.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 01.01.26.
//


import Foundation
import SwiftOpenAPISpec
import Yams

public enum SwiftOpenAPICLIError: LocalizedError {
    case missingArgument
    case fileNotFound(String)
    case invalidURL(String)
    case loadFailed(String)

    public var errorDescription: String? {
        switch self {
        case .missingArgument:
            return "Usage: SwiftOpenAPICLI <path-to-openapi.(yaml|yml|json)>"
        case .fileNotFound(let path):
            return "File not found: \(path)"
        case .invalidURL(let path):
            return "Invalid URL or path: \(path)"
        case .loadFailed(let reason):
            return "Failed to load specification: \(reason)"
        }
    }
}

/// Testbare CLI-Logik: gibt 0 bei Erfolg, !=0 bei Fehlern zurück.
/// Erwartet mindestens ein Argument: Pfad zur OpenAPI-Datei.
public struct SwiftOpenAPICLIApp {
    public init() {}

    @discardableResult
    public func run(args: [String], stdout: inout TextOutputStream, stderr: inout TextOutputStream) async -> Int {
        do {
            guard args.count >= 2 else {
                throw SwiftOpenAPICLIError.missingArgument
            }
            let path = args[1]

            // Erzeuge URL aus Pfad (lokal)
            let url: URL
            if path.hasPrefix("file://"), let u = URL(string: path) {
                url = u
            } else {
                url = URL(fileURLWithPath: path)
            }

            // Verifiziere Existenz
            if !FileManager.default.fileExists(atPath: url.path) {
                throw SwiftOpenAPICLIError.fileNotFound(path)
            }

            // Spezifikation laden
            let spec = try await OpenAPISpecification.read(url: url, documentLoader: YamsDocumentLoader())

            // Beispielausgabe: OpenAPI-Version und Titel
            let version = spec.version ?? "(unknown)"
            let title = spec.info?.title ?? "(no title)"
            var out = ""
            out += "OpenAPI: \(version)\n"
            out += "Title: \(title)\n"
            stdout.write(out)

            return 0
        } catch {
            stderr.write("Error: \(error.localizedDescription)\n")
            return 1
        }
    }
}