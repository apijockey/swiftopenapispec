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
    
    static func fixture(fixtureName: String, subDirectory : String ) ->   ManifestEntry? {
        do {
            let url = try fixtureURL("expectedDiagnostics", subDirectory: subDirectory)
            let fixtures = try specString(url)["cases"]
            guard let fixtures = fixtures as? [Any] else {
                fatalError("Could not load fixtures")
                
            }
            
            var entry: ManifestEntry? = nil
            for fixture in fixtures {
                var diagnostics: [ExpectedDiagnostic] = []
                if let dictionary = fixture as? [String: Any] {
                    let fixturename = dictionary["fixture"] as? String ?? ""
                    if fixturename != fixtureName {
                        continue
                    }
                    let shouldPass = dictionary["shouldPass"] as? Bool ?? false
                    let expected = dictionary["expected"] as? [Any] ?? []
                    let onlyThese = dictionary["onlyThese"] as? Bool ?? false
                    
                    for expect in expected {
                        if let entry  = expect as? StringDictionary {
                            let code =  entry["code"] as? String ?? ""
                            let pointer =  entry["pointer"] as? String ?? ""
                            let rule =  entry["rule"] as? String ?? ""
                            let severity =  entry["severity"] as? String ?? ""
                            let messageContains =  entry["messageContains"] as? String ?? ""
                            let entry = ExpectedDiagnostic(code: code, pointer: pointer, rule: rule, severity: severity, messageContains: messageContains)
                            diagnostics.append(entry)
                        }
                        
                    }
                    entry = ManifestEntry(fixture: fixtureName, shouldPass: shouldPass, expected: diagnostics, onlyThese: onlyThese)
                    
                }
            }
            return entry
        } catch {
            fatalError("Could not load fixtures")
            
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
    private static func specString(_ url : URL) throws -> StringDictionary {
        
        do {
            let data = try Data(contentsOf: url)
            guard let string = String(data: data, encoding: .utf8),
                  let map = try Yams.load(yaml: string) as? StringDictionary else {
                throw Self.Errors.notUTF8(url.absoluteString)
            }
            return map
        } catch {
            throw Self.Errors.unreadable(url.absoluteString, error)
        }
    }
    @Test("DEBUG.")
    func debug_schemarules() async throws {
        
        let fixtureName = "10-schematests-inconsistentformat"
        let subDirectory = "Resources/3_0/invalid"
        let rule = "OAS.ReferencesMustHaveRef"
        let bundle = Bundle.module
        print("Bundle URL:", bundle.bundleURL.path)
        
        
        guard let resourceUrl = Bundle.module.url(forResource: fixtureName , withExtension: "yaml", subdirectory: subDirectory) else {
            throw FixtureErrors.notFound(fixtureName )
        }
        let oasYaml = try Self.specString(resourceUrl)
        let apiSpec = try OpenAPISpecification.read(
            unflattened: oasYaml,
            url: fixtureName ,
            documentLoader: YamsDocumentLoader()
        )
        
        let ctx = ValidationContext(version: .v30, dialect: .oas30, baseURI: fixtureName, operationIds: [])
        let objectLoader = YamsDocumentLoader()
        var resolver = JSONPointerResolver(baseURL: resourceUrl) { url in
            try await objectLoader.load(from: url)
        }
        let results = try await Validator.validateSchema(spec: apiSpec, ctx: ctx, baseURI: resourceUrl.absoluteString, resolver: &resolver)
         
        
        
    }
    @Test("Schema rules for 3.0 hit",arguments: [
        "05-response-invalidType",
        "05-response-invalidPropertyType",
        "10-schematests-inconsistentformat"
    ])
    func schemaRulesHit(resource : String) async throws {
    let subDirectory = "Resources/3_0/invalid"
       guard let resourceUrl = Bundle.module.url(forResource: resource , withExtension: "yaml", subdirectory: subDirectory) else {
            throw FixtureErrors.notFound(resource )
        }
        
        
        let oasYaml = try Self.specString(resourceUrl)
        let apiSpec = try OpenAPISpecification.read(
            unflattened: oasYaml,
            url:resource ,
            documentLoader: YamsDocumentLoader()
        )
        guard let fixture = Self.fixture(fixtureName: resource, subDirectory: subDirectory) else {
            throw FixtureErrors.notFound(resource )
        }
        let ctx = ValidationContext(version: .v30, dialect: .oas30, baseURI: resource, operationIds: [])
        let objectLoader = YamsDocumentLoader()
        var resolver = JSONPointerResolver(baseURL: resourceUrl, loadDocument:  objectLoader.load(from:))
        
        let diags = try await Validator.validateSchema(spec: apiSpec, ctx: ctx, baseURI: resource, resolver: &resolver)
        #expect(diags.count == fixture.expected.count)

        for (diag,expected) in zip(diags,fixture.expected) {
            #expect(diag.message.contains(expected.messageContains))
            #expect(diag.pointer == expected.pointer)
            #expect(diag.rule == expected.rule)
            #expect(diag.code.rawValue == expected.code)
            #expect(diag.severity.rawValue == expected.severity)
        }
        
        
    
    }
    @Test("debug schema rules")
    func debugSchemaRulesHit() async throws {
        let resource = "10-schematests-invalidAllOfAnyOf"
    let subDirectory = "Resources/3_0/invalid"
       guard let resourceUrl = Bundle.module.url(forResource: resource , withExtension: "yaml", subdirectory: subDirectory) else {
            throw FixtureErrors.notFound(resource )
        }
        
        
        let oasYaml = try Self.specString(resourceUrl)
        let apiSpec = try OpenAPISpecification.read(
            unflattened: oasYaml,
            url:resource ,
            documentLoader: YamsDocumentLoader()
        )
        guard let fixture = Self.fixture(fixtureName: resource, subDirectory: subDirectory) else {
            throw FixtureErrors.notFound(resource )
        }
        let ctx = ValidationContext(version: .v30, dialect: .oas30, baseURI: resource, operationIds: [])
        let objectLoader = YamsDocumentLoader()
        var resolver = JSONPointerResolver(baseURL: resourceUrl, loadDocument:  objectLoader.load(from:))
        
        let diags = try await Validator.validateSchema(spec: apiSpec, ctx: ctx, baseURI: resource, resolver: &resolver)
        #expect(diags.count == fixture.expected.count)

        for (diag,expected) in zip(diags,fixture.expected) {
            #expect(diag.message.contains(expected.messageContains))
            #expect(diag.pointer == expected.pointer)
            #expect(diag.rule == expected.rule)
            #expect(diag.code.rawValue == expected.code)
            #expect(diag.severity.rawValue == expected.severity)
        }
        
        
    
    }
}
