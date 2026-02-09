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
    typealias ManifestEntry = TestHelpers.ManifestEntry

    @Test("DEBUG.")
    func debug_schemarules() async throws {
        let fixtureName = "10-schematests-wrongNullableComposition"
        let subDirectory = "Resources/3_0/invalid"
        let rule = "OAS.ReferencesMustHaveRef"
        let bundle = Bundle.module
        print("Bundle URL:", bundle.bundleURL.path)
        
        guard let resourceUrl = Bundle.module.url(forResource: fixtureName, withExtension: "yaml", subdirectory: subDirectory) else {
            throw FixtureErrors.notFound(fixtureName)
        }
        
        let dict = try TestHelpers.loadFixtureDictionary(fixtureName, subDirectory: subDirectory)
        let apiSpec = try OpenAPISpecification.read(unflattened: dict, url: fixtureName, documentLoader: YamsDocumentLoader())
        
        guard let fixture = TestHelpers.fixtureManifest(fixtureName: fixtureName, subDirectory: subDirectory) else {
            throw FixtureErrors.notFound(fixtureName)
        }
        
        try await TestHelpers.validateSchemaAndCompare(
            apiSpec: apiSpec,
            fixture: fixture,
            resourceUrl: resourceUrl,
            resourceName: fixtureName,
            version: ValidationContext.OASVersion.v30,
            dialect: ConverterConfig.Dialect.oas30
        )
    }

    @Test("Schema rules for 3.0 hit", arguments: [
        "05-response-invalidType",
        "05-response-invalidPropertyType",
        "invalid_schema"
    ])
    func schemaRulesHit(resource: String) async throws {
        let subDirectory = "Resources/3_0/invalid"
        
        guard let resourceUrl = Bundle.module.url(forResource: resource, withExtension: "yaml", subdirectory: subDirectory) else {
            throw FixtureErrors.notFound(resource)
        }
        
        let dict = try TestHelpers.loadFixtureDictionary(resource, subDirectory: subDirectory)
        let apiSpec = try OpenAPISpecification.read(unflattened: dict, url: resource, documentLoader: YamsDocumentLoader())
        
        guard let fixture = TestHelpers.fixtureManifest(fixtureName: resource, subDirectory: subDirectory) else {
            throw FixtureErrors.notFound(resource)
        }
        
        try await TestHelpers.validateSchemaAndCompare(
            apiSpec: apiSpec,
            fixture: fixture,
            resourceUrl: resourceUrl,
            resourceName: resource,
            version: ValidationContext.OASVersion.v30,
            dialect: ConverterConfig.Dialect.oas30
        )
    }

    @Test("Schema Warning rules for 3.0 hit", arguments: [
        "10-schematests-inconsistentformat",
        "10-schematests-invalidAllOfAnyOf",
        "10-schematests-identifiableNullable",
        "10-schematests-invalidreadwriteonly",
        "10-schematests-wrongconstraints",
        "10-schematests-wrongformat"
    ])
    func schemaWarningRulesHit(resource: String) async throws {
        let subDirectory = "Resources/3_0/invalid"
        
        guard let resourceUrl = Bundle.module.url(forResource: resource, withExtension: "yaml", subdirectory: subDirectory) else {
            throw FixtureErrors.notFound(resource)
        }
        
        let dict = try TestHelpers.loadFixtureDictionary(resource, subDirectory: subDirectory)
        let apiSpec = try OpenAPISpecification.read(unflattened: dict, url: resource, documentLoader: YamsDocumentLoader())
        
        guard let fixture = TestHelpers.fixtureManifest(fixtureName: resource, subDirectory: subDirectory) else {
            throw FixtureErrors.notFound(resource)
        }
        
        try await TestHelpers.validateSchemaAndCompare(
            apiSpec: apiSpec,
            fixture: fixture,
            resourceUrl: resourceUrl,
            resourceName: resource,
            version: ValidationContext.OASVersion.v30,
            dialect: ConverterConfig.Dialect.oas30
        )
    }
}
