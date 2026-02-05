//
//  Schema30Tests.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 22.01.26.
//

import Foundation
import Testing
import Yams
@testable import SwiftOpenAPISpec

@Suite("Schema 3.0 Validation")
struct Schema30ValidationTests {
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
        let onlyThese : Bool
    }
    
    static func fixtureManifest(fixtureName: String, subDirectory : String ) ->   ManifestEntry? {
        do {
            let url = try fixtureURL("expectedDiagnostics", subDirectory: subDirectory)
            let fixtures = try loadYamlJson(url: url)
            guard case let .object(fixtureObject) = fixtures,
                  case let .array(fixtures) = fixtureObject["cases"]
            else {
                fatalError("Could not load fixtures")
                
            }
            
            var entry: ManifestEntry? = nil
            for fixtureElement in fixtures {
                if case let  .object(fixture) = fixtureElement {
                    var diagnostics: [ExpectedDiagnostic] = []
                    let fixturename = fixture["fixture"]?.stringValue
                    if fixturename != fixtureName {
                        continue
                    }
                    let shouldPass = fixture["shouldPass"]?.boolValue ?? false
                    let expected = fixture["expected"]?.arrayValue ?? []
                    let onlyThese = fixture["onlyThese"]?.boolValue ?? false
                    for expect in expected {
                        if let entry  = expect.objectValue {
                            let code =  entry["code"]?.stringValue ?? ""
                            let pointer =  entry["pointer"]?.stringValue ?? ""
                            let rule =  entry["rule"]?.stringValue ?? ""
                            let severity =  entry["severity"]?.stringValue ?? ""
                            let messageContains =  entry["messageContains"]?.stringValue ?? ""
                            let entry = ExpectedDiagnostic(code: code, pointer: pointer, rule: rule, severity: severity, messageContains: messageContains)
                            diagnostics.append(entry)
                        }

                    }
                    entry = ManifestEntry(fixture: fixtureName, shouldPass: shouldPass, expected: diagnostics, onlyThese: onlyThese)
                    
                }
                
            }

            return entry
        } catch {
            fatalError(" Could not load fixtures: \(error)")
           
        }
       
    }
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
    private static func fixtureURL(_ resource: String, subDirectory : String, ext: String = "yaml") throws -> URL {
        let name = "\(resource).\(ext)"
        
        guard let url = Bundle.module.url(forResource: resource, withExtension: ext, subdirectory: subDirectory) else {
            throw FixtureErrors.notFound(name)
        }
        return url
    }
    private static func loadYamlJson(url : URL) throws -> JSONValue {
        var diagnostics: [Diagnostic] = []
        do {
            
            let data = try Data(contentsOf: url)
            guard let string = String(data: data, encoding: .utf8),
                  let map = try Yams.load(yaml: string)   else  {
                throw Self.Errors.notUTF8(url.absoluteString)
            }
            let jsonValue = try JSONValue(from: map, diagnostics: &diagnostics)
            return jsonValue
        } catch {
            print(diagnostics)
            throw Self.Errors.unreadable(url.absoluteString, error)
        }
    }
    private static func loadYamlJson(_ resource: String, ext: String = "yaml", subDirectory : String? = nil) throws -> JSONValue {
        let name = "\(resource).\(ext)"

        guard let url = Bundle.module.url(forResource: resource, withExtension: ext, subdirectory: subDirectory) else {
            throw Self.Errors.notFound(name)
        }
        return try loadYamlJson(url: url)
        
    }
    private func fixtureMap(_ resource: String, ext: String = "yaml", subDirectory : String? = nil) throws -> JSONValue {
        let name = "\(resource).\(ext)"

        guard let url = Bundle.module.url(forResource: resource, withExtension: ext, subdirectory: subDirectory) else {
            throw Self.Errors.notFound(name)
        }

        do {
            let data = try Data(contentsOf: url)
            guard let string = String(data: data, encoding: .utf8),
                  let map = try Yams.load(yaml: string)  as? [String:Any] else  {
                throw Self.Errors.notUTF8(name)
            }
            let jsonValue = try JSONValue(from: map)
            return jsonValue
        } catch {
            throw Self.Errors.unreadable(name, error)
        }
    }
    @Test("DEBUG.")
    func debug_schemarules() async throws {
        
        let fixtureName = "10-schematests-wrongformat"
        let subDirectory = "Resources/3_0/invalid"
        let rule = "OAS.ReferencesMustHaveRef"
        let bundle = Bundle.module
        print("Bundle URL:", bundle.bundleURL.path)
        
        
        guard let resourceUrl = Bundle.module.url(forResource: fixtureName , withExtension: "yaml", subdirectory: subDirectory) else {
            throw FixtureErrors.notFound(fixtureName )
        }
       
        
        guard case let .object(yaml) = try fixtureMap(fixtureName, subDirectory: subDirectory) else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:fixtureName , documentLoader: YamsDocumentLoader())
        
        let ctx = ValidationContext(version: .v30, dialect: .oas30, baseURI: fixtureName, operationIds: [])
        let objectLoader = YamsDocumentLoader()
        var resolver = JSONPointerResolver(baseURL: resourceUrl) { url in
            try await objectLoader.load(from: url)
        }
        guard let fixture = Self.fixtureManifest(fixtureName: fixtureName, subDirectory: subDirectory) else {
            throw FixtureErrors.notFound(fixtureName )
        }
        let errors = try await Validator.validateSchema(spec: apiSpec, ctx: ctx, baseURI: resourceUrl.absoluteString, resolver: &resolver)
        let diags = errors.filter({ $0.severity == .error })
        #expect(diags.count == fixture.expected.count)

        for (diag,expected) in zip(diags,fixture.expected) {
            #expect(diag.message.contains(expected.messageContains))
            #expect(diag.pointer == expected.pointer)
            #expect(diag.rule == expected.rule)
            #expect(diag.code.rawValue == expected.code)
            #expect(diag.severity.rawValue == expected.severity)
        }
        
        
    }
    @Test("Schema rules for 3.0 hit",arguments: [
        "05-response-invalidType",
        "05-response-invalidPropertyType",
        "10-schematests-wrongformat"
    ])
    func schemaRulesHit(resource : String) async throws {
    let subDirectory = "Resources/3_0/invalid"
       guard let resourceUrl = Bundle.module.url(forResource: resource , withExtension: "yaml", subdirectory: subDirectory) else {
            throw FixtureErrors.notFound(resource )
        }
        
        
        guard case let .object(yaml) = try fixtureMap(resource, subDirectory: subDirectory) else {
            Issue.record("Expected .object(let)")
            return
        }
        let apiSpec = try OpenAPISpecification.read(unflattened: yaml, url:resource , documentLoader: YamsDocumentLoader())
       
        guard let fixture = Self.fixtureManifest(fixtureName: resource, subDirectory: subDirectory) else {
            throw FixtureErrors.notFound(resource )
        }
        let ctx = ValidationContext(version: .v30, dialect: .oas30, baseURI: resource, operationIds: [])
        let objectLoader = YamsDocumentLoader()
        var resolver = JSONPointerResolver(baseURL: resourceUrl, loadDocument:  objectLoader.load(from:))
        
        let diags = try await Validator.validateSchema(spec: apiSpec, ctx: ctx, baseURI: resource, resolver: &resolver)
        let errors = diags.filter({ $0.severity == .error })
        #expect(errors.count == fixture.expected.count)

        for (error,expected) in zip(errors,fixture.expected) {
            #expect(error.message.contains(expected.messageContains))
            #expect(error.pointer == expected.pointer)
            #expect(error.rule == expected.rule)
            #expect(error.code.rawValue == expected.code)
            #expect(error.severity.rawValue == expected.severity)
        }
        
        
    
    }
   
}
