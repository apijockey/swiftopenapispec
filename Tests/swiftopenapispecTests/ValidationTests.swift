//
//  ValidationTests.swift
//  SwiftOpenAPISpec
//
//  Created by Patric Dubois on 02.01.26.
//

import Testing
import Foundation
import Yams
@testable import SwiftOpenAPISpec

@Suite("Validation")
struct ValidationTests {
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
                return nil
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
    func debug_rules() async throws {
        let fixtureName = "03-minimal-30-noDescription"
        let subDirectory = "Resources/3_0/invalid"
        let rule = "OAS.ReferencesMustHaveRef"
        let bundle = Bundle.module
        print("Bundle URL:", bundle.bundleURL.path)

        let resourcesRoot = try #require(bundle.resourceURL)
        print("Resources root:", resourcesRoot.path)
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
        let runner = RuleRunner.defaultRuleRunner
     
        let unfilteredDiags = runner.run(spec: apiSpec, ctx: ctx)
        let diags = unfilteredDiags.filter { diagnotics in
            diagnotics.rule == rule
        }
        guard let fixture = Self.fixture(fixtureName: fixtureName, subDirectory: subDirectory) else {
            throw FixtureErrors.notFound(fixtureName )
        }
        #expect(fixture.shouldPass == diags.isEmpty)
        #expect(fixture.shouldPass || fixture.onlyThese == true ?  fixture.expected.count == diags.count : fixture.expected.count <= diags.count)
        for (result,expected) in zip(diags,fixture.expected) {
            #expect(result.code.rawValue == expected.code)
            #expect(result.message.contains(expected.messageContains))
            #expect(result.pointer.contains(expected.pointer))
            #expect(result.rule == expected.rule)
            #expect(result.severity.rawValue == expected.severity)
        }
    }
    
    
    @Test("DEBUG schema rules.")
    func debug_schemarules() async throws {
        let fixtureName = "06-refcomponentNotResolvable"
        let subDirectory = "Resources/3_0/invalid"
        let rule = "OAS.ResolveRefs"
        let bundle = Bundle.module
        print("Bundle URL:", bundle.bundleURL.path)

        let resourcesRoot = try #require(bundle.resourceURL)
        print("Resources root:", resourcesRoot.path)
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
        let unfilteredDiags =  try await Validator.validateSchema(spec: apiSpec, ctx: ctx, baseURI: resourceUrl.absoluteString, resolver: &resolver)
        let diags = unfilteredDiags.filter { diagnotics in
            diagnotics.rule == rule
        }
        guard let fixture = Self.fixture(fixtureName: fixtureName, subDirectory: subDirectory) else {
            throw FixtureErrors.notFound(fixtureName )
        }
        #expect(fixture.shouldPass == diags.isEmpty)
        #expect(fixture.shouldPass || fixture.onlyThese == true ?  fixture.expected.count == diags.count : fixture.expected.count <= diags.count)
        
    }
    
    
    @Test("Schema rules hit",arguments: [
        ("05-response-invalidType","Schema.SupportedTypes"),
        ("05-response-invalidPropertyType","Schema.SupportedTypes")
    ])
    func schemaRulesHit(resource : String, rule : String) async throws {
        
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
        
        let ctx = ValidationContext(version: .v30, dialect: .oas30, baseURI: resource, operationIds: [])
        let objectLoader = YamsDocumentLoader()
        var resolver = JSONPointerResolver(baseURL: resourceUrl, loadDocument:  objectLoader.load(from:))
        let diags = try await Validator.validateSchema(spec: apiSpec, ctx: ctx, baseURI: resource, resolver: &resolver)
        #expect(diags.count >= 1)
        let expectedDiagnostic = try #require(diags.first(where: { $0.rule == rule }))
        #expect(expectedDiagnostic.message.contains("unknown type"))
    
    }
     
    @Test("spec rules do not hit.", arguments: [
        "01-minimal-30",
         "03-minimal-30-noContent"
        ])
    func noSpecRulesHits(resource: String) async throws {
        let subDirectory = "Resources/3_0/valid"
       guard let resourceUrl = Bundle.module.url(forResource: resource , withExtension: "yaml", subdirectory: subDirectory) else {
            throw FixtureErrors.notFound(resource )
        }
       
        
              
        let oasYaml = try Self.specString(resourceUrl)
        let apiSpec = try OpenAPISpecification.read(
            unflattened: oasYaml,
            url:resource ,
            documentLoader: YamsDocumentLoader()
        )
        
        let ctx = ValidationContext(version: .v30, dialect: .oas30, baseURI: resource, operationIds: [])
        let runner = RuleRunner.defaultRuleRunner
        let diags = runner.run(spec: apiSpec, ctx: ctx)
        #expect(diags.isEmpty)
        
    }
    
    @Test(
        "Spec rules hit.",
        arguments: { () -> [(String,String)] in
            return [
                ("01-minimal-30-missingInfo","OAS.RequiredOpenAPIFixedFields"),
                ("02-minimal-30-missingPaths","OAS.RequiredOpenAPIFixedFields"),
                ("03-minimal-30-unsupportedV3", "OAS.UnsupportedVersion3"),
                ("02-minimal-30-missingInfoVersion","OAS.RequiredOpenAPIFixedInfoFields"),
                ("02-minimal-30-missingInfoTitle","OAS.RequiredOpenAPIFixedInfoFields"),
                ("03-minimal-30-unsupportedPathName","OAS.PathsMustStartWithSlashRule"),
                ("03-minimal-30-unsupportedHTTPMethod","OAS.SupportedHTTPMethodRule"),
                ("03-minimal-30-missingResponse","OAS.OperationMustHaveResponses"),
                ("03-minimal-30-invalidHTTPStatus","OAS.SupportedHTPStatusRule"),
                ("03-minimal-30-noDescription","OAS.ReferencesMustHaveRef")
            ]
        }()
    )
    func specRulesHits(setup : (String,String)) async throws {
            guard let fixture = Self.fixture(fixtureName: setup.0, subDirectory: "Resources/3_0/invalid"),
                  let resourceUrl = Bundle.module.url(forResource: setup.0 , withExtension: "yaml", subdirectory: "Resources/3_0/invalid") else {
                throw FixtureErrors.notFound(setup.0 )
            }
            let oasYaml = try Self.specString(resourceUrl)
            let apiSpec = try OpenAPISpecification.read(
                unflattened: oasYaml,
                url:setup.0 ,
                documentLoader: YamsDocumentLoader()
            )
            
            let ctx = ValidationContext(version: .v30, dialect: .oas30, baseURI: setup.0, operationIds: [])
            let runner = RuleRunner.defaultRuleRunner
            
            let unfilteredDiags = runner.run(spec: apiSpec, ctx: ctx)
        let diags = unfilteredDiags.filter { diagnotics in
            diagnotics.rule == setup.1
        }
            #expect(fixture.shouldPass == diags.isEmpty,  "mismatch for \(setup.0),shouldPass   = \(fixture.shouldPass), but got \(diags.count) diagnostics")
            #expect(fixture.shouldPass || fixture.onlyThese == true ?  fixture.expected.count == diags.count : fixture.expected.count <= diags.count, "number of diagnostics does not match expectations")
            for (result,expected) in zip(diags,fixture.expected) {
                #expect(result.code.rawValue == expected.code, "code: \(result) != \(expected)")
                #expect(result.message.contains(expected.messageContains), "message: \(result) != \(expected)")
                #expect(result.pointer.starts(with: expected.pointer), "pointer: \(result) not as \(expected)")
                #expect(result.rule == expected.rule,  "rule: \(result) != \(expected)")
                #expect(result.severity.rawValue == expected.severity,  "severity: \(result) != \(expected)")
                
            }
            
        }
   

    
    
     @Test("All schema $refs resolve")
    func validateRefs() async throws {
        let subDirectory = "Resources/3_1/valid"
        let fixture = "openapi"
        guard let resourceUrl = Bundle.module.url(forResource: fixture , withExtension: "yaml", subdirectory: subDirectory) else {
            throw FixtureErrors.notFound(fixture)
        }
        let loader = YamsDocumentLoader()
        
        let spec = try await OpenAPISpecification.read(url: resourceUrl,documentLoader: loader)
        
        var resolver = JSONPointerResolver(baseURL: resourceUrl, loadDocument: { u in
            try await loader.load(from: u)
        })
        
        
        
        //Beispiel: components.schemas
        let ctx = ValidationContext(version: .v30, dialect: .oas30, baseURI: resourceUrl.absoluteString, operationIds: [])
        
       
        let diags = try await Validator.validateRefs(spec: spec, baseURI: resourceUrl.absoluteString, ctx: ctx, resolver: &resolver)
        print(diags)
        #expect(diags.count == 5)
        
        
        
    }
    
    @Test("All internal schema $refs are identified")
   func identifyRefs() async throws {
       let subDirectory = "Resources/3_1/valid"
       let fixture = "openapi"
       guard let resourceUrl = Bundle.module.url(forResource: fixture , withExtension: "yaml", subdirectory: subDirectory) else {
           throw FixtureErrors.notFound(fixture)
       }
       let loader = YamsDocumentLoader()
       
       let spec = try await OpenAPISpecification.read(url: resourceUrl,documentLoader: loader)
       
       var resolver = JSONPointerResolver(baseURL: resourceUrl, loadDocument: { u in
           try await loader.load(from: u)
       })
       
       
       
       //Beispiel: components.schemas
       let ctx = ValidationContext(version: .v30, dialect: .oas30, baseURI: resourceUrl.absoluteString, operationIds: [])
       
      
       let diags = try await Validator.validateRefs(spec: spec, baseURI: resourceUrl.absoluteString, ctx: ctx, resolver: &resolver)
     
       #expect(diags.count == 5)
       for diag in diags {
           print("\(diag.pointer) - \(diag.message)")
       }
       
       #expect(diags.contains { diag in
           diag.pointer == "/paths/~1pets/patch/requestBody/content/application~1json/schema/oneOf/0/$ref"
           && diag.message.contains("#/components/schemas/Cat'")
       })
       #expect(diags.contains { diag in
           diag.pointer == "/paths/~1pets/patch/requestBody/content/application~1json/schema/oneOf/1/$ref"
           && diag.message.contains("#/components/schemas/Dog'")
       })
       
       #expect(diags.contains { diag in
           diag.pointer == "/paths/~1pets/post/requestBody/content/application~1xml/schema/$ref"
           && diag.message.contains("'#/components/schemas/Pet'")
       })
       
       #expect(diags.contains { diag in
           diag.pointer == "/paths/~1pets/post/requestBody/content/application~1x-www-form-urlencoded/schema/$ref"
           && diag.message.contains("'#/components/schemas/PetForm'")
       })
       
       #expect(diags.contains { diag in
           diag.pointer == "/paths/~1pets/post/requestBody/content/application~1json/schema/$ref"
           && diag.message.contains("'#/components/schemas/Pet'")
       })
       

    
      
   }
    @Test("internal and external schema $refs are identified")
    func identifyeExternalRefs() async throws {
        let subDirectory = "Resources/3_1/valid"
        let fixture = "35-ext-components"
        guard let resourceUrl = Bundle.module.url(forResource: fixture , withExtension: "yaml", subdirectory: subDirectory) else {
            throw FixtureErrors.notFound(fixture)
        }
        let loader = YamsDocumentLoader()
        
        let spec = try await OpenAPISpecification.read(url: resourceUrl,documentLoader: loader)
        
        var resolver = JSONPointerResolver(baseURL: resourceUrl, loadDocument: { u in
            try await loader.load(from: u)
        })
        
        
        
        //Beispiel: components.schemas
        let ctx = ValidationContext(version: .v30, dialect: .oas30, baseURI: resourceUrl.absoluteString, operationIds: [])
        
        
        let diags =  Validator.findOccurrences(spec: spec, baseURI: resourceUrl.absoluteString, ctx: ctx, resolver: &resolver)
        for diag in diags {
            print(diag.refString)
        }
        #expect(diags.count == 5)
    }
    @Test("cascading $refs in separate files are identified")
    func identifyeCascadingRefs() async throws {
        let subDirectory = "Resources/3_0/valid"
        let fixture = "refs-advanced-main"
        guard let resourceUrl = Bundle.module.url(forResource: fixture , withExtension: "yaml", subdirectory: subDirectory) else {
            throw FixtureErrors.notFound(fixture)
        }
        let loader = YamsDocumentLoader()
        
        let spec = try await OpenAPISpecification.read(url: resourceUrl,documentLoader: loader)
        
        var resolver = JSONPointerResolver(baseURL: resourceUrl, loadDocument: { u in
            try await loader.load(from: u)
        })
        
        
        
        //Beispiel: components.schemas
        let ctx = ValidationContext(version: .v30, dialect: .oas30, baseURI: resourceUrl.absoluteString, operationIds: [])
        
        
        let diags =  Validator.findOccurrences(spec: spec, baseURI: resourceUrl.absoluteString, ctx: ctx, resolver: &resolver)
        for diag in diags {
            print(diag.refString)
        }
        #expect(diags.count == 25)
    }
}

