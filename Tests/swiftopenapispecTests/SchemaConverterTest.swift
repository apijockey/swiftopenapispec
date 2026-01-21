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
//  Created by Patric Dubois on 19.12.25.
//

import Testing
import Yams
import Foundation
@testable import SwiftOpenAPISpec

@Suite("Converter Tests")
struct SchemaConverterTestSuite {
    let objectLoader = YamsDocumentLoader()
   
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
   
    private func fixtureMap(_ resource: String, ext: String = "yaml") throws -> StringDictionary {
        let name = "\(resource).\(ext)"

        guard let url = Bundle.module.url(forResource: resource, withExtension: ext) else {
            throw Self.Errors.notFound(name)
        }

        do {
            let data = try Data(contentsOf: url)
            guard let string = String(data: data, encoding: .utf8),
            let yaml = try Yams.load(yaml: string) as? StringDictionary else {
                throw Self.Errors.notUTF8(name)
            }
            return yaml
        } catch {
            throw Self.Errors.unreadable(name, error)
        }
    }
    @Test("setup correct")
    func setup() async throws {
        let name = "01-minimal-30"
        guard let url = Bundle.module.url(forResource: name, withExtension: "yaml", subdirectory: "Resources/3_0/valid") else {
            throw Self.Errors.notFound(name)
        }
        let apiSpec = try await OpenAPISpecification.read(url: url)
        let resolver = JSONPointerResolver(baseURL: url) { url in
            try await objectLoader.load(from: url)
        }
        var converter = SchemaConverter(config: ConverterConfig(dialect: .oas30), resolver: resolver)
        let schema = try #require(apiSpec[path: "/ping"]?.operations[operationID: "ping"]?.responses?[key:"200"]?.content[key:"application/json"]?.schema)
        let convertResult =  try await converter.convert(schema: schema)
        switch convertResult {
            case .object(let o):
            #expect(o.properties.count == 1)
            #expect(o.required == ["ok"])
        default:
            Issue.record("not object")
        }
        print(convertResult)
    }
    @Test("JSON Schema for reference is resolved")
    func resolveReferences() async throws {
        let name = "05-responses-status-default"
        guard let url = Bundle.module.url(forResource: name, withExtension: "yaml",subdirectory: "Resources/3_0/valid") else {
            throw Self.Errors.notFound(name)
        }
        let apiSpec = try await OpenAPISpecification.read(url: url)
        let resolver = JSONPointerResolver(baseURL: url) { url in
            try await objectLoader.load(from: url)
        }
        var converter = SchemaConverter(config: ConverterConfig(dialect: .oas30), resolver: resolver)
        let schema = try #require(apiSpec[path: "/create"]?.operations[operationID: "create"]?.responses?[key:"default"]?.content[key:"application/json"]?.schema)
        let convertResult = try await converter.convert(schema: schema)
        switch convertResult {
        case .object(let openAPIObjectType):
            #expect(openAPIObjectType.properties.count == 1)
            #expect(openAPIObjectType.properties[key: "message"]?.type is OpenAPIStringType)
            #expect(openAPIObjectType.required == ["message"])
        default:
            Issue.record("not object")
        
        }
    }
    @Test("anyof contains all referenced schemas")
    func anyof() async throws {
        let name = "08-oneof-anyof-allof"
        guard let url = Bundle.module.url(forResource: name, withExtension: "yaml",subdirectory: "Resources/3_0/valid") else {
            throw Self.Errors.notFound(name)
        }
        let apiSpec = try await OpenAPISpecification.read(url: url)
        let resolver = JSONPointerResolver(baseURL: url) { url in
            try await objectLoader.load(from: url)
        }
        var converter = SchemaConverter(config: ConverterConfig(dialect: .oas30), resolver: resolver)
        let schema = try #require(apiSpec[path: "/shape"]?.operations[operationID: "createShape"]?.requestBody?.contents[key:"application/json"]?.schema)
        let convertResult = try await converter.convert(schema: schema)
        switch convertResult {
        case .oneOf(let oneOfType):
            guard case let .object(circle) = try #require(oneOfType.first) else {
                Issue.record("Expected first oneOf element to be .object")
                return
            }
            
            #expect(circle.properties.count == 1)
            #expect(circle.properties[key: "r"]?.type is OpenAPIDoubleType)
        default:
            Issue.record("not object")
        
        }
    }
}
