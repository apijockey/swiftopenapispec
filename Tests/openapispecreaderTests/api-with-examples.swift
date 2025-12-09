//
//  Test.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 09.12.25.
//

import Foundation
import Testing
@testable import SwiftOpenAPISpec

struct APIWithExamplesTests {

    enum Errors: LocalizedError, CustomStringConvertible {
        case notFound(String)
        case unreadable(String, Error)
        case notUTF8(String)

        var description: String {
            switch self {
            case .notFound(let name): return "Fixture not found: \(name)"
            case .unreadable(let name, let err): return "Fixture unreadable: \(name) (\(err))"
            case .notUTF8(let name): return "Fixture not UTF-8 encoded: \(name)"
            }
        }
    }
    private func specString(_ resource: String, ext: String = "yaml") throws -> String {
        let name = "\(resource).\(ext)"

        guard let url = Bundle.module.url(forResource: resource, withExtension: ext) else {
            throw Self.Errors.notFound(name)
        }

        do {
            let data = try Data(contentsOf: url)
            guard let string = String(data: data, encoding: .utf8) else {
                throw Self.Errors.notUTF8(name)
            }
            return string
        } catch {
            throw Self.Errors.unreadable(name, error)
        }
    }
    @Test("Test OpanAPI Object")
    func minimal() async throws {
        let yaml = try specString("minimal-3_0", ext: "json")
        
        let apiSpec = try OpenAPISpec.read(text: yaml)
        #expect(apiSpec.version == "3.0.3")
        #expect(apiSpec.servers.count == 0)
        #expect(apiSpec.paths.count > 0)
        let pingAPIPath = try #require(apiSpec[path: "/ping"])
        #expect(pingAPIPath.key == "/ping")
        #expect(pingAPIPath.operations.count == 1)
        let getPingOperation = try #require(pingAPIPath[operationId: "ping"].first)
        #expect(getPingOperation.responses?.count == 1)
    }
    

}
