//
//  TestHelpers.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 22.01.26.
//

import Foundation
import Testing
import Yams
@testable import SwiftOpenAPISpec

/// Common test helper functions and structures for OpenAPI specification testing
struct TestHelpers {
    
    enum AssertionGroup : String{
        case OAS, Schema
    }
    
    struct ExpectedDiagnostic: Codable, Equatable {
        let code: String
        let pointer: String
        let rule: String
        let severity: String
        let messageContains: String
    }
    
    struct ManifestEntry: Codable {
        let fixture: String
        let shouldPass: Bool
        let expected: [ExpectedDiagnostic]
        let onlyThese: Bool
    }
    
    enum TestError: LocalizedError, CustomStringConvertible {
        case notFound(String)
        case unreadable(String, Error)
        case notUTF8(String)
        case invalidFixtureFormat(String)
        case yamsError(String)
        case notAJsonObject(String)
        
        var description: String {
            switch self {
            case .notFound(let name): return "Fixture not found: \(name)"
            case .unreadable(let name, let err): return "Fixture unreadable: \(name) (\(err))"
            case .notUTF8(let name): return "Fixture not UTF-8 encoded: \(name)"
            case .invalidFixtureFormat(let name): return "Invalid fixture format: \(name)"
            case .notAJsonObject(let string) : return "not a valid JSON object: \(string)"
            case .yamsError(let string): return "YAML parsing error: \(string)"
            }
        }
    }
    
    /// Load fixture manifest from expectedDiagnostics.yaml
    /// - Parameters:
    ///   - fixtureName: Name of the fixture to find
    ///   - subDirectory: Subdirectory containing the fixture
    ///   - bundle: Bundle to load from (defaults to module bundle)
    /// - Returns: ManifestEntry for the specified fixture, or nil if not found
    static func fixtureManifest(fixtureName: String, subDirectory: String, bundle: Bundle = .module) -> ManifestEntry? {
        do {
            let url = try fixtureURL("expectedDiagnostics", subDirectory: subDirectory, bundle: bundle)
            let fixtures = try loadYamlJson(url: url, bundle: bundle)
            
            guard case let .object(fixtureObject) = fixtures,
                  case let .array(fixtures) = fixtureObject["cases"]
            else {
                throw TestError.invalidFixtureFormat("expectedDiagnostics.yaml in \(subDirectory)")
            }
            
            for fixtureElement in fixtures {
                if case let .object(fixture) = fixtureElement {
                    let fixturename = fixture["fixture"]?.stringValue
                    if fixturename != fixtureName {
                        continue
                    }
                    
                    let shouldPass = fixture["shouldPass"]?.boolValue ?? false
                    let expectedArray = fixture["expected"]?.arrayValue ?? []
                    let onlyThese = fixture["onlyThese"]?.boolValue ?? false
                    
                    var diagnostics: [ExpectedDiagnostic] = []
                    for expect in expectedArray {
                        if let entry = expect.objectValue {
                            let code = entry["code"]?.stringValue ?? ""
                            let pointer = entry["pointer"]?.stringValue ?? ""
                            let rule = entry["rule"]?.stringValue ?? ""
                            let severity = entry["severity"]?.stringValue ?? ""
                            let messageContains = entry["messageContains"]?.stringValue ?? ""
                            let diagnostic = ExpectedDiagnostic(
                                code: code,
                                pointer: pointer,
                                rule: rule,
                                severity: severity,
                                messageContains: messageContains
                            )
                            diagnostics.append(diagnostic)
                        }
                    }
                    
                    return ManifestEntry(
                        fixture: fixtureName,
                        shouldPass: shouldPass,
                        expected: diagnostics,
                        onlyThese: onlyThese
                    )
                }
            }
            
            return nil
        } catch {
            Issue.record("Could not load fixtures: \(error)")
            return nil
        }
    }
    
    /// Load YAML fixture as JSONValue
    /// - Parameters:
    ///   - resource: Resource name (without extension)
    ///   - ext: File extension (default: "yaml")
    ///   - subDirectory: Subdirectory path
    ///   - bundle: Bundle to load from
    /// - Returns: JSONValue representing the fixture
    static func loadFixture(_ resource: String, ext: String = "yaml", subDirectory: String? = nil, bundle: Bundle = .module) throws -> JSONValue {
        let name = "\(resource).\(ext)"
        
        guard let url = bundle.url(forResource: resource, withExtension: ext, subdirectory: subDirectory) else {
            throw TestError.notFound(name)
        }
        
        return try loadYamlJson(url: url, bundle: bundle)
    }
    
    /// Load YAML fixture as Dictionary (for OpenAPI specs)
    /// - Parameters:
    ///   - resource: Resource name (without extension)
    ///   - ext: File extension (default: "yaml")
    ///   - subDirectory: Subdirectory path
    ///   - bundle: Bundle to load from
    /// - Returns: Dictionary representing the fixture
    static func loadFixtureDictionary(_ resource: String, ext: String = "yaml", subDirectory: String? = nil, bundle: Bundle = .module) throws -> [String: JSONValue] {
        guard case let .object(yaml) = try loadFixture(resource, ext: ext, subDirectory: subDirectory, bundle: bundle) else {
            throw TestError.invalidFixtureFormat("\(resource).\(ext)")
        }
        return yaml
    }
    
    /// Get URL for a resource
    /// - Parameters:
    ///   - resource: Resource name (without extension)
    ///   - subDirectory: Subdirectory path
    ///   - ext: File extension
    ///   - bundle: Bundle to load from
    /// - Returns: URL for the resource
    static func fixtureURL(_ resource: String, subDirectory: String, ext: String = "yaml", bundle: Bundle = .module) throws -> URL {
        let name = "\(resource).\(ext)"
        
        guard let url = bundle.url(forResource: resource, withExtension: ext, subdirectory: subDirectory) else {
            throw TestError.notFound(name)
        }
        return url
    }
    
    /// Load YAML file and convert to JSONValue
    /// - Parameters:
    ///   - url: URL of the YAML file
    ///   - bundle: Bundle for error reporting
    /// - Returns: JSONValue representing the YAML content
    private static func loadYamlJson(url: URL, bundle: Bundle) throws -> JSONValue {
        var diagnostics: [Diagnostic] = []
        do {
            let data = try Data(contentsOf: url)
            guard let string = String(data: data, encoding: .utf8),
                  let map = try Yams.load(yaml: string) else {
                throw TestError.notUTF8(url.absoluteString)
            }
            let jsonValue = try JSONValue(from: map, diagnostics: &diagnostics)
            return jsonValue
        } catch {
            throw TestError.unreadable(url.absoluteString, error)
        }
    }
    
    /// Validate schema and compare with expected diagnostics
    /// - Parameters:
    ///   - apiSpec: OpenAPI specification to validate
    ///   - fixture: Expected manifest entry
    ///   - resourceUrl: URL of the resource
    ///   - resourceName: Name of the resource
    ///   - version: OpenAPI version
    ///   - dialect: OpenAPI dialect
    ///   - bundle: Bundle for loading
    static func assertValidations(
        apiSpec: OpenAPISpecification,
        fixture: ManifestEntry,
        resourceUrl: URL,
        resourceName: String,
        version: ValidationContext.OASVersion,
        dialect: ConverterConfig.Dialect,
        bundle: Bundle = .module,
        assertions: [AssertionGroup]
        
    ) async throws {
        let ctx = ValidationContext(version: version, dialect: dialect, baseURI: resourceName, operationIds: [])
        let objectLoader = YamsDocumentLoader()
        var resolver = JSONPointerResolver(baseURL: resourceUrl) { url in
            try await objectLoader.load(from: url)
        }
        
        var errors = [Diagnostic]()
        if assertions.contains(.OAS) {
            errors = try await Validator.validate(spec: apiSpec, baseURI: resourceUrl.absoluteString, ctx: ctx, resolver: &resolver)
        }
        if assertions.contains(.Schema) {
            errors = try await Validator.validateSchema(spec: apiSpec, ctx: ctx, baseURI: resourceUrl.absoluteString, resolver: &resolver)
        }
        
        #expect(errors.count == fixture.expected.count, "Expected \(fixture.expected.count) errors, got \(errors.count)")
        let sortedErrors = errors.sorted { lhs, rhs in lhs.pointer < rhs.pointer }
        let sortedExpected = fixture.expected.sorted { lhs, rhs in lhs.pointer < rhs.pointer}
        for (error, expected) in zip(sortedErrors, sortedExpected) {
            #expect(error.message.contains(expected.messageContains), "Error message should contain '\(expected.messageContains)', got: \(error.message)")
            #expect(error.pointer == expected.pointer, "Error pointer should be '\(expected.pointer)', got: '\(error.pointer)'")
            #expect(error.rule == expected.rule, "Error rule should be '\(expected.rule)', got: '\(error.rule)'")
            #expect(error.code.rawValue == expected.code, "Error code should be '\(expected.code)', got: '\(error.code.rawValue)'")
            #expect(error.severity.rawValue == expected.severity, "Error severity should be '\(expected.severity)', got: '\(error.severity.rawValue)'")
        }
    }
    static func loadSpec(yamlString : String) throws -> OpenAPISpecification{
        do {
            guard let map = try Yams.load(yaml: yamlString)  as? [String:Any] else  {
                throw  Self.TestError.yamsError("not a Dictionary")
            }
            let jsonValue = try JSONValue(from: map)
            guard case let .object(specObject) = jsonValue else {
                throw  Self.TestError.notAJsonObject("root of generated YAML is not an object")
            }
            return try OpenAPISpecification.read(unflattened: specObject)
            
        }
        catch {
            throw  Self.TestError.yamsError(error.localizedDescription)
        }
        
        
        
    }
}
